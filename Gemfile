source :rubygems

gemspec

group :development, :test do
  gem 'ruby-debug', :platforms => :ruby_18
  gem 'ruby-debug19', :platforms => :ruby_19

  # these are only needed if you are using the factories in the gem --
  # wish there was a way to have them optionally loaded
  gem 'factory_girl', :path => "~/work/github/factory_girl"
  gem 'hoodwink', :path => "~/work/github/hoodwink"
  gem 'supermodel', :path => "~/work/github/supermodel"
  gem 'faker'
  gem 'wrong'
end

group :development do
  #gem 'ruby_gntp'
  #gem 'growl'
end
