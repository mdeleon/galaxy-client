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

def get_headers(opts={})
  { "Authorization" => "Basic Zm9vOmJhcg==", "Accept" => "application/json" }.merge(opts)
end

def post_headers(opts={})
  { "Authorization" => "Basic Zm9vOmJhcg==", "Content-Type" => "application/json" }.merge(opts)
end
