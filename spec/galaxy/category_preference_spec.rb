require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/category_preference"

module Galaxy
  describe CategoryPreference do
    subject { Galaxy::CategoryPreference.new(:user_id => "user-slug",
      :id => "category-slug",
      :created_at => nil) }

    it_timeifies :created_at

    describe "#destroy" do
      it "should send a DELETE request to /api/v2/users/:user_id/category_preferences/:id" do
        mock_galaxy(:delete,
                    "/api/v2/users/user-slug/category_preferences/category-slug.json",
                    delete_headers,
                    nil,
                    200)

        response = subject.destroy

        response.code.should eq(200)
      end
    end
  end
end