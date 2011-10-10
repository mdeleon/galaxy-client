require "yajl"
require "rspec"
require "webmock/rspec"
require "galaxy"

RSpec.configure do |c|
  c.mock_with :rspec

  c.before(:suite) do
    Galaxy::Config.api_key "foobar"
    Galaxy::Config.base_uri "http://homerun.offerengine.com/api/v2/"
  end
end

def fixture(path)
  File.new File.expand_path("../fixtures/#{path}", __FILE__)
end