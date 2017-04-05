Gem::Specification.new do |s|
  s.name        = 'webhook'
  s.version     = '2.0.0'
  s.date        = '2017-04-05'
  s.summary     = "A wrapper for Stripe webhooks"
  s.description = "This simple gem will take a webhook post, check the event on Stripe, and get basic details about a charge"
  s.authors     = ["Gregor MacLennan"]
  s.email       = 'gmaclennan@digital-democracy.org'
  s.files       = ["lib/webhook.rb"]
  s.homepage    = 'http://github.com/digidem/webhook-gem'

  s.add_dependency('stripe', '~>2.1')
  s.add_dependency('json', '~>2.0')
  s.add_dependency('rack', '~>1.6')
end
