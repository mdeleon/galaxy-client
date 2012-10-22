module Galaxy
  class Category < Galaxy::Base
    timeify :created_at

    def self.sorted_list
      #Should not display improper categories
      cats = Category.all.inject([]) do |list, elem|
        category_for_display.index(elem.name) ? list << elem : list
      end
      cats.sort_by{|c|category_for_display.index(c.name)}
    end
  end
end
