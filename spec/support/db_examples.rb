shared_examples_for 'the sub-class of DBs' do
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

  describe '#each with block' do
    before do
      @result = []
      db.each do |k, v|
        @result << v
      end
    end
    subject { @result.sort }
    it      { should == %w(21 ABC Tokyo) }
  end

  describe '#keys' do
    subject { db.keys.sort }

    it { should == %w(addr age name) }

    describe 'raw db' do
      subject { db.db.keys.sort }

      it { should == %w(db::addr db::age db::name) }
    end
  end

  describe '#values' do
    subject { db.values.sort }

    it { should == %w(21 ABC Tokyo) }
  end
end
