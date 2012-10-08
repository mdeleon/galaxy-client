module Galaxy
  class CategoryPreference < Galaxy::Base
    timeify :created_at
    
    def destroy
      connection.delete "/api/v2/users/#{user_id}/category_preferences/#{id}.json"
    end
  end
end
