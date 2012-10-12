module Galaxy
  class SavedDeal < Galaxy::Base
    belongs_to :deal
    timeify :created_at
  end
end
