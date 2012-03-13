class String
  def slugify
    self.downcase.gsub(/\s+/, '').underscore.downcase.dasherize
  end
end
