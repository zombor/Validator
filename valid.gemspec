lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'validation/version'

Gem::Specification.new do |s|
  s.name = 'valid'
  s.version = Validation::VERSION
  s.authors = ['Jeremy Bush']
  s.email = ['contractfrombelow@gmail.com']
  s.summary = 'A standalone, generic object validator for ruby'
  s.homepage = %q{https://github.com/zombor/Validator}

  s.files = Dir.glob("lib/**/*") + ["README.md"]
  s.require_path = 'lib'
end
