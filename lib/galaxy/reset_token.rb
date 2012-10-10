module Galaxy
  class ResetToken < Galaxy::Base
    def user
      User.find(user_id)
    end
  end
end
