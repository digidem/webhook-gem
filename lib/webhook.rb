require 'stripe'
require 'json'
require 'rack/utils'

module Webhook
  # Reads post content and looks up key details from a Stripe event.
  class Stripe
    # Makes these class variables accessible via Stripe['type'] etc.
    attr_accessor :type, :email, :name, :amount, :description, :date
    
    def initialize(post_content)
      # Parse the body content as JSON
      params = JSON.parse(post_content)
      # For more security, retrieve the actual event from Stripe to make sure it really exists.
      # This is ::Stripe::Event rather than Stripe::Event to namespace correctly.
      event = ::Stripe::Event.retrieve(params['id'])
      case event.type
      when "charge.succeeded"
        @charge = event.data.object
        if @charge.customer.nil?
          @type = "single.donation"
          @name = @charge.card.name
          @amount = @charge.amount
          @description = "Stripe website donation"
          @date = Time.at(@charge.created.to_i)
        end
      when "invoice.payment_succeeded"
        @invoice = event.data.object
        @type = "recurring.donation"
        @customer = ::Stripe::Customer.retrieve(:id => @invoice.customer, :expand => ['default_card'])
        puts @customer
        @name = @customer.default_card.name
        puts @name
        @email = @customer.email
        @amount = @invoice.total
        @plan = @customer.subscription.plan
        puts @plan
        @date = Time.at(@invoice.date.to_i)
      when "subscription.created"
        @subscription = event.data.object
        @type = "subscription.created"
        @customer = ::Stripe::Customer.retrieve(:id => @subscription.customer, :expand => ['default_card'])
        @name = @customer.default_card.name
        @email = @customer.email
        @amount = @subscription.plan.amount.to_i * @subscription.quantity.to_i
        @plan = @subscription.plan
        @date = Time.at(@customer.start.to_i)
      end
    end
    
    def firstname
      # This adds a method Webhook::Stripe.firstname which returns just the first name.
      self.name.split(' ').first
    end

  end
  
  class Paypal
    attr_accessor :type, :email, :name, :amount, :description, :date

    def initialize(post_content)
      raise NoDataError if post_content.to_s.empty?

      @params  = {}
      @raw     = ""

      parse(post_content)
      
      @email = @params['payer_email']
      @name = [@params['first_name'], @params['last_name']].join(" ")
      @amount = @params['mc_gross'].to_f*100
      @description = @params['item_name']
      @date = DateTime.parse(@params['payment_date']).to_time
    end
    
    def completed?
      type == :Completed
    end
    
    def validated?
      request = RestClient.post "https://www.paypal.com/cgi-bin/webscr", @raw + "&cmd=_notify-validate"
      raise StandardError.new("Faulty paypal result: #{request.body}") unless ["VERIFIED", "INVALID"].include?(request.body)
      request.body == "VERIFIED"
    end
    
    private
    
    def type
      @type ||= (@params['payment_status'] ? @params['payment_status'].to_sym : nil)
    end

    # Take the posted data and move the relevant data into a hash
    def parse(post_content)
      @raw = post_content
      @params = Rack::Utils.parse_query(post_content)
      # Rack allows duplicate keys in queries, we need to use only the last value here
      @params.each{|k,v| self.params[k] = v.last if v.is_a?(Array)}
    end
  end
end