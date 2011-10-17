require "rspec"
require "galaxy"

RSpec.configure do |c|
  c.mock_with :rspec

  c.before(:suite) do
    Galaxy::Base.user      = "foo"
    Galaxy::Base.password  = "bar"
    Galaxy::Base.site      = "https://partner.offerengine.com/api/v2/?"
  end
end

def fixture(path)
  File.new File.expand_path("../fixtures/#{path}", __FILE__)
end
