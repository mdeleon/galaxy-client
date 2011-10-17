### Install

Add this line to your gemfile

gem 'galaxy-client', :git => "git@github.com:demandchain/galaxy-client.git"

### Configure

Create an initializer with the following code:

Galaxy::Base.user      = "foo"

Galaxy::Base.password  = "bar"

Galaxy::Base.site      = "https://partner.offerengine.com/api/v2"


### Usage


Galaxy::User.create(:email => "foo@bar.com") # creates user with email param

user = Galaxy::User.find("abd02123")   # finds user with id

See documentation for more details:

https://github.com/demandchain/galaxy-client/wiki/Consumer-API-Doc