module Galaxy
  class Promotion < Galaxy::Base
    # Apply a promotion to user
    # @param [Hash] params
    #   :user_id is the id of the user that we will apply the promotion for.
    def apply_to_user(user_id)
      params = {:user_id => user_id}
      post(:apply_to_user, params)
    end
  end
end
