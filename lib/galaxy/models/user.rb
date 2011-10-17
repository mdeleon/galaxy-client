module Galaxy
  class User < Galaxy::Base
    # lockdown schema if we want.
    # self.schema = {'name' => :string, 'age' => :integer }

    def reset_password
      put(:reset_password)
    end

    def blacklist
      put(:blacklist)
    end
  end
end
