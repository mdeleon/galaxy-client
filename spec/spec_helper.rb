require "rspec"
require "galaxy"

def perform_mock?
  !ENV["INTEGRATION"]
end

def mock_galaxy(action, path, request_headers = {}, body = nil, status = 200, response_headers = {})
  return unless perform_mock?
  ActiveResource::HttpMock.respond_to do |mock|
    mock.send action, path, request_headers, body, status, response_headers
  end
end

RSpec.configure do |c|
  c.mock_with :rspec

  c.before(:suite) do
    Galaxy::Base.user      = "foo"
    Galaxy::Base.password  = "bar"
    Galaxy::Base.site      = "https://partner.offerengine.com/api/v2/?"
  end
end

def get_headers(opts={})
  { "Authorization" => "Basic Zm9vOmJhcg==", "Accept" => "application/json" }.merge(opts)
end

def post_headers(opts={})
  { "Authorization" => "Basic Zm9vOmJhcg==", "Content-Type" => "application/json" }.merge(opts)
end

def delete_headers(opts={})
  get_headers
end
