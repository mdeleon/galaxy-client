class Array
  def slugify
    self.join('-').slugify
  end
end
