Gem::Specification.new do |s|
  s.name        = 'webhook'
  s.version     = '0.0.1'
  s.date        = '2013-03-14'
  s.summary     = "A wrapper for Stripe webhooks"
  s.description = "This simple gem will take a webhook post, check the event on Stripe, and get basic details about a charge"
  s.authors     = ["Gregor MacLennan"]
  s.email       = 'gmaclennan@digital-democracy.org'
  s.files       = ["lib/webhook.rb"]
  s.homepage    = 'http://github.com/digidem/webhook-gem'
  
  s.add_dependency('stripe', '~>1.7')
end