module Timeify
  def timeify(*field_names)
    field_names.each do |field_name|
      self.class_eval <<-EOF
      def #{field_name}
        super ? Time.parse(super.to_s) : nil
      end
      EOF
    end
  end
end
