module Galaxy
  class Location < Galaxy::Base
    timeify :created_at
    belongs_to :address

  end
end
