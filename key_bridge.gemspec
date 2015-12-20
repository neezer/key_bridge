$:.push File.expand_path('../lib', __FILE__)
require 'key_bridge/version'

Gem::Specification.new do |s|
  s.name        = 'key_bridge'
  s.version     = KeyBridge::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.date        = '2015-12-19'
  s.summary     = 'Ruby Hash Mapper and keypath getter/setter'
  s.description = 'A gem that allows translating a hash an arbitrary format.'
  s.authors     = ['Evan Sherwood']
  s.email       = 'evan@sherwood.io'
  s.homepage    = 'https://github.com/neezer/key_bridge'
  s.license     = 'MIT'

  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- test/*`.split("\n")
  s.require_paths         = ['lib']
  s.required_ruby_version = '>= 2.2.3'

  s.add_dependency('activesupport', '~> 4.2.5')
end
