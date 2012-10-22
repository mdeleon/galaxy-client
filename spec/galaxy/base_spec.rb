require File.expand_path('../../spec_helper', __FILE__)
require "galaxy/base"

describe Galaxy::Base do
  class Galaxy::TopLevelObject < Galaxy::Base
  end

  class TopLevelObject < Galaxy::TopLevelObject
  end

  class Galaxy::Model < Galaxy::Base
  end

  class Galaxy::Bar < Galaxy::Base
    has_many :deals
    has_many :things, :class => TopLevelObject
  end

  class Galaxy::Foo < Galaxy::Base
    has_many :bars, :class => Galaxy::Bar, :default_params => Proc.new { {:dyn_param => 13} }
  end

  class Galaxy::Food < Galaxy::Base
    has_many :bars, :class => Galaxy::Bar, :default_params => {:const_param => 11}
  end

  class Galaxy::Animal < Galaxy::Base
    has_one :nose, :class => Galaxy::Bar
  end

  it "includes root in json" do
    Galaxy::Model.include_root_in_json.should be
  end

  it "format is json" do
    Galaxy::Model.format.should == ActiveResource::Formats::JsonFormat
  end

  describe ".raw_with_prefix" do
    it "returns the prefix + path" do
      expect(Galaxy::Model.raw_with_prefix("test/jhk/qw")).to eq(
        "/api/v2/test/jhk/qw"
      )
    end
  end

  describe ".has_many" do
    subject {Galaxy::Bar.new(:id => 4)}
    context 'default params are set' do
      it "can access its 'things' (top level class)" do
        TopLevelObject.should_receive(:find).with(:all, :from => "/api/v2/bars/4/things.json", :params => {}).and_return([])
        subject.things
      end
      context 'default params are a proc' do
        subject{Galaxy::Foo.new(:id =>1)}

        it 'should merge default params with method params' do
          Galaxy::Bar.should_receive(:find).with do |*args|
            expect(args[0]).to eq(:all)
            expect(args[1][:params][:dyn_param]).to eq(13)
            expect(args[1][:params][:test]).to eq(14)
          end

          subject.bars(:test => 14)
        end
      end

      context 'default params are a hash' do
        subject{Galaxy::Food.new(:id => 1)}

        it 'should merge default params with method params' do
          Galaxy::Bar.should_receive(:find).with do |*args|
            expect(args[0]).to eq(:all)
            expect(args[1][:params][:const_param]).to eq(11)
            expect(args[1][:params][:test]).to eq(15)
          end

          subject.bars(:test => 15)
        end
      end
    end

    context 'instance has resource attributes' do
      subject {Galaxy::Bar.new(:id => 4, :deals => [:title => 'test'])}
      it 'should construct a model from the attributes' do
        expect(subject.deals.first.title).to eq('test')
        expect(subject.deals.first.class).to eq(Galaxy::Deal)
      end

      it 'should not make any resource call' do
        Galaxy::Deal.should_not_receive(:find)
        subject.deals
      end
    end

    context 'instance has no resource attributes' do
      subject {Galaxy::Bar.new(:id => 4)}
      let (:returned_deal) {Galaxy::Deal.new(:title => 'deal')}
      before {Galaxy::Deal.stub(:find).and_return([returned_deal])}

      it 'should contruct a model from the attribute' do
        expect(subject.deals.first.title).to eq('deal')
        expect(subject.deals.first.class).to eq(Galaxy::Deal)
      end

      it 'should make the resource call' do
        Galaxy::Deal.should_receive(:find)
        subject.deals
      end
    end
  end

  describe ".has_one" do
    subject {Galaxy::Animal.new(:id => 1)}
    it 'shold call has_many and limit one' do
      Galaxy::Bar.should_receive(:find).with do |*args|
        expect(args[0]).to eq(:one)
      end
      subject.nose
    end
  end

  describe ".belongs_to" do
    class Galaxy::A < Galaxy::Base
      belongs_to :b
    end
    class Galaxy::B < Galaxy::Base; end

    context 'default params are set' do
      context 'default params are a proc' do
        class Galaxy::Foo < Galaxy::Base
          belongs_to :bar, :default_params => Proc.new {|x| {:dyn_param => x.id} }
        end

        subject{Galaxy::Foo.new(:id =>55, :bar_id => 'key')}

        it 'should merge default params with method params' do
          Galaxy::Bar.should_receive(:find).with do |*args|
            expect(args[1][:params][:dyn_param]).to eq(subject.id)
            expect(args[1][:params][:test]).to eq(6)
          end

          subject.bar(:test => 6)
        end
      end

      context 'default params are a hash' do
        class Galaxy::Food < Galaxy::Base
          belongs_to :bar, :class => Galaxy::Bar, :default_params => {:const_param => 77}
        end

        subject{Galaxy::Food.new(:id => 1,:bar_id => 'test')}

        it 'should merge default params with method params' do
          Galaxy::Bar.should_receive(:find).with do |*args|
            expect(args[1][:params][:const_param]).to eq(77)
            expect(args[1][:params][:test]).to eq(15)
          end

          subject.bar(:test => 15)
        end
      end
    end

    context 'instance has resource attribute' do
      subject {Galaxy::A.new(:id => 4, :b => {:key => 'test'})}

      it 'should construct a model from the attributes' do
        expect(subject.b.key).to eq('test')
        expect(subject.b.class).to eq(Galaxy::B)
      end

      it 'should not make any resource call' do
        Galaxy::B.should_not_receive(:find)
        subject.b
      end
    end

    context 'instance has resource_id' do
      subject {Galaxy::A.new(:id => 4, :b_id => 1)}
      let(:b_stub) {{:somehting => 'test'}}
      before {Galaxy::B.stub(:find => Galaxy::B.new(b_stub))}

      it 'should contruct a model from the attribute' do
        expect(subject.b.somehting).to eq('test')
        expect(subject.b.class).to eq(Galaxy::B)
      end

      it 'should make the resoure call' do
        Galaxy::B.should_receive(:find)
        expect(subject.b.somehting).to eq('test')
      end
    end

    context 'instance has no resouce key or attributes' do
      it 'should raise error' do
        subject {Galaxy::A.new(:id => 4)}
        expect{subject.junk}.to raise_error
      end
    end
  end
end
