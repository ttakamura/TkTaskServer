require 'spec_helper'

describe DB::Delta do
  let(:db)         { DB::Delta.new(DB::Hash.new, record_db) }
  let(:record_db)  { DB::Record.new(DB::Hash.new) }
  let(:data_store) { Dropbox::DataStore.new handle: 'my_handle', dsid: 'default', rev: 10 }
  let(:delta1)     { data_store.records.new(tid: 'table1', rowid: '11', data: {name: 'tom'}).to_delta  }
  let(:delta2)     { data_store.records.new(tid: 'table1', rowid: '12', data: {name: 'koji'}).to_delta }
  let(:delta3)     { data_store.records.new(tid: 'table1', rowid: '13', data: {name: 'jo'}).to_delta   }

  before do
    delta1.rev = 10
    delta2.rev = 11

    db[10] = delta1
    db[11] = delta2
  end

  subject { db }

  describe '#notify_change' do
    let(:record) { data_store.records.new(tid: 'table1', rowid: '20', data: {name: 'Yuki'}) }

    before do
      @changes = []
      db.watch do |record|
        @changes << record
      end
      db.notify_change record
    end

    subject { @changes.first }
    it      { should == record }
  end

  describe '#apply_change' do
    context 'create' do
      let(:record) { data_store.records.new(tid: 'table1', data: {id: 123, name: 'Yuki'}) }
      let(:delta)  { record.to_delta }

      before do
        expect(delta.changes.first).to be_a Dropbox::RecordChanges::Create
      end

      it 'should insert a record' do
        expect {
          db.apply_change delta
        }.to change{ db.record_db[ record.rowid ] }.from(nil).to(record)
      end
    end

    context 'update' do
      let(:old_record) { data_store.records.new(tid: 'table1', rowid: '20', data: {name: 'Hoge'}) }
      let(:new_record) { data_store.records.new(tid: 'table1', rowid: '20', data: {name: 'Yuki'}) }
      let(:delta)      { new_record.to_delta }

      before do
        expect(delta.changes.first).to be_a Dropbox::RecordChanges::Update
        record_db['20'] = old_record
      end

      it 'should update a record' do
        expect {
          db.apply_change delta
        }.to change{ record_db['20'] }.from(old_record).to(new_record)
      end
    end

    context 'delete' do

    end
  end

  describe '#rebuild!' do
    before  { db.rebuild! }
    subject { record_db['11'] }
    its([:name]) { should == 'tom' }
  end

  describe '#current_rev' do
    subject { db.current_rev }
    it      { should == 11 }
  end

  describe '#[]=' do
    before  { db[12] = delta3 }
    subject { db[12] }
    it      { should == delta3 }
  end

  describe '#each' do
    subject { db.to_enum(:each).to_a }
    it      { should == [[10, delta1], [11, delta2]] }
  end

  describe '#to_key' do
    subject { db.to_key(123) }

    it { should == 'db::0000000123' }
  end

  describe '#from_key' do
    subject { db.from_key('db::0000000123') }

    it { should == 123 }
  end
end
