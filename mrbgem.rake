MRuby::Gem::Specification.new('mruby-m2x') do |spec|
  spec.version = '0.0.1'
  spec.license = 'MIT'
  spec.summary = 'Client library for AT&T\'s M2X API'
  spec.description = 'AT&T\'s M2X is a cloud-based fully managed data storage service for network connected machine-to-machine (M2M) devices. From trucks and turbines to vending machines and freight containers, M2X enables the devices that power your business to connect and share valuable data.'
  spec.authors = ['Joe McIlvain']

  spec.add_dependency('mruby-http')
  spec.add_dependency('mruby-socket')
  spec.add_dependency('mruby-json')
end
