require 'stripe'
require 'json'

module Webhook
  # Reads post content and looks up key details from a Stripe event.
  class Stripe
    # Makes these class variables accessible via Stripe['type'] etc.
    attr_accessor :type, :email, :name, :amount, :description
    
    def initialize(post_content)
      # Parse the body content as JSON
      params = JSON.parse(post_content)
      # For more security, retrieve the actual event from Stripe to make sure it really exists.
      # This is ::Stripe::Event rather than Stripe::Event to namespace correctly.
      event = ::Stripe::Event.retrieve(params['id'])
      @type = event.type
      # Only respond to "charge.succeeded" events
      if @type == "charge.succeeded"
        # See https://stripe.com/docs/api#events for the structure of the event object.
        charge = event.data.object
        # The email address is stored in the Customer object.
        @email = ::Stripe::Customer.retrieve(charge.customer).email
        # In Stripe, customer objects do not have a name, we are using the name from the card.
        @name = charge.card.name
        @amount = charge.amount
        @description = charge.description
      end
    end
    
    def firstname
      # This adds a method Webhook::Stripe.firstname which returns just the first name.
      self.name.split(' ').first
    end

  end
end