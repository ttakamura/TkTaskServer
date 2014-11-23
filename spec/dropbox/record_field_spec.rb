require 'spec_helper'

describe Dropbox::FieldSerializer do
  describe '#serialize_value' do
    include Dropbox::FieldSerializer
    subject { serialize_value value }

    context 'Integer' do
      let(:value) { 19 }

      it { should == {'I' => '19'} }
    end

    context 'Time' do
      let(:time)  { Time.at(1234567890) }
      let(:value) { time }

      it { should == {'T' => '1234567890000'} }
    end

    context 'default' do
      let(:value) { true }

      it { should == true }
    end
  end
end

describe Dropbox::FieldParser do
  describe '#parse_value' do
    include Dropbox::FieldParser
    subject { parse_value value }

    context 'Array' do
      let(:value) { [{'I' => '10'}, {'I' => '20'}] }

      it { should == [10, 20] }
    end

    context 'String' do
      let(:value) { 'hello world' }

      it { should == 'hello world' }
    end

    context 'Bool' do
      let(:value) { true }

      it { should == true }
    end

    context 'Integer' do
      let(:value) { {'I' => '12345'} }

      it { should == 12345 }
    end

    context 'Time' do
      let(:value) { {'T' => '1234567890000'} }

      it { should == Time.at(1234567890) }
    end
  end
end
