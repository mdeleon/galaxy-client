require File.expand_path('../lib/galaxy/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "galaxy-client"
  s.version     = Galaxy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["HomeRun"]
  s.email       = ["support@homerun.com"]
  s.homepage    = "http://github.com/demandchain/galaxy-client"
  s.summary     = "API helpers for HomeRun Galaxy APIs"
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "activeresource"

  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "yajl-ruby"
  s.add_development_dependency "yard"
  s.add_development_dependency "rdiscount"
  s.add_development_dependency "rdoc"

  s.add_development_dependency "wrong"
  s.add_development_dependency "guard-rspec"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end
