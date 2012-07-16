module Galaxy
  class Promotion < Galaxy::Base
    # Apply a promotion to user
    # @param [Hash] params
    #   :user_id is the id of the user that we send the invitations on behalf of.
    def apply_to_user(params = {})
      params.assert_valid_keys(:user_id)
      post(:apply_to_user, params)
    end
  end
end
