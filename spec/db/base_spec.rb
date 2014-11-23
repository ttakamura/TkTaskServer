require 'spec_helper'

describe DB::Base do
  let(:db) { DB::Hash.new }

  before do
    db['name'] = 'ABC'
    db['age']  = '21'
    db['addr'] = 'Tokyo'
  end

  subject { db }

  describe '#get' do
    subject { db['name'] }
    it      { should == 'ABC' }

    describe 'raw value' do
      subject { db.db['db::name'] }
      it      { should == '{"v":"ABC"}' }
    end
  end

  describe '#delete' do
    before  { db.delete 'name' }
    subject { db['name'] }
    it      { should be_nil }
  end

  describe '#put' do
    before  { db['hoge'] = value }
    subject { db['hoge'] }

    context 'String' do
      let(:value) { 'ABC' }

      it { should == 'ABC' }
    end

    context 'Integer' do
      let(:value) { 9876 }

      it { should == 9876 }
    end

    context 'Float' do
      let(:value) { 123.45 }

      it { should == 123.45 }
    end

    context 'Bool' do
      let(:value) { true }

      it { should == true }
    end

    context 'Array' do
      let(:value) { [1,2,3] }

      it { should == [1,2,3] }
    end

    context 'Hash' do
      let(:value) { {'name' => 'hoge'} }

      it { should == {'name' => 'hoge'} }
    end
  end

  describe '#includes?' do
    subject { db.includes? 'name' }
    it      { should == true }
  end

  describe '#each' do
    subject { db.each.to_a.sort }

    it { should == [["addr", "Tokyo"], ["age", "21"], ["name", "ABC"]] }
  end

  describe '#keys' do
    its(:keys) { should == %w(name age addr) }

    describe 'raw db' do
      subject { db.db.keys }

      it { should == %w(db::name db::age db::addr) }
    end
  end

  describe '#values' do
    its(:values) { should == %w(ABC 21 Tokyo) }
  end
end
