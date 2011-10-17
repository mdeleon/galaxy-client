module Galaxy
  class User < Galaxy::Base
    def reset_password
      put(:reset_password)
    end

    def blacklist
      put(:blacklist)
    end
  end
end
