require 'spec_helper'

describe DropbModel, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD}  do
  let(:klass) do
    Class.new(DropbModel) do
      self.table_id = 'sandbox'
      attribute :id
      attribute :name
      attribute :age
    end
  end

  describe 'class' do
    def stub_record attrs
      obj = OpenStruct.new(attrs)
      stub(obj).data { obj }
      obj
    end

    let(:rows) do
      rows = {
        'a11' => stub_record(id: '11', name: 'Tom',  age: 29, tid: 'sandbox'),
        'b22' => stub_record(id: '22', name: 'John', age: 32, tid: 'sandbox'),
        'c33' => stub_record(id: '33', name: 'Koji', age: 28, tid: 'hoge')
      }
      def rows.all
        map{ |k,v| v }
      end
      rows
    end

    let(:db) do
      db = stub!
      db.records { rows }
      db
    end

    before do
      stub(klass).db { db }
    end

    subject { klass }

    describe '.find' do
      subject { klass.find('b22') }

      it         { should be_a klass }
      its(:id)   { should == '22' }
      its(:name) { should == 'John' }
    end

    describe '.all' do
      subject { klass.all }

      its(:count)     { should == 2 }
      its('first.id') { should == '11' }
      its('last.id')  { should == '22' }
    end

    describe '.each_attribute' do
      subject { klass.each_attribute.map{ |k, v| v } }

      its(:first) { should == {name: :id,  index: 0} }
      its(:last)  { should == {name: :age, index: 2} }
    end

    describe '.attribute' do
      let(:record) { klass.find('b22') }

      subject { record }

      describe '#name' do
        its(:name) { should == 'John' }
      end

      describe '#name=' do
        before { record.name = 'Foo' }
        its(:name) { should == 'Foo' }
      end
    end
  end

  describe 'instance' do
    let(:yumi) { klass.new id: '66', name: 'Yumi', age: 21 }

    subject    { yumi }
    its(:name) { should == 'Yumi' }

    describe '#save!' do
      it 'should insert a record to DB' do
        expect {
          yumi.save!
        }.to change{ yumi.send(:db).records.all.count }.by(1)

        expect(klass.find(yumi.rowid).name).to eq 'Yumi'
      end
    end

    describe '#destroy!' do
      before { yumi.save! }

      it 'should delete a record from DB' do
        expect {
          yumi.destroy!
        }.to change{ yumi.send(:db).records.all.count }.by(-1)

        expect(klass.find(yumi.rowid)).to eq nil
      end
    end
  end
end
