require "spec_helper"
require "galaxy/partner"

module Galaxy
  describe Partner do
    describe "#config_hash" do
      subject do
        slug = "someslug"

        Galaxy::Partner.new(slug:   slug,
                            id:     slug,
                            config: { some: { nested: "valuehere!" } })
      end

      it "makes a hash from config" do
        subject.config.some.nested.should eq("valuehere!")
        subject.config_hash[:some][:nested].should eq("valuehere!")
      end
    end
  end
end