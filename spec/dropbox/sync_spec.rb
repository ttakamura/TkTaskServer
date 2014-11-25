require 'spec_helper'

describe Dropbox::Sync, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD}  do
  let(:sync)    { Dropbox::Sync.new store }
  let(:store)   { Dropbox::DataStore.new dsid: 'test1', handle: 'my_handle', rev: 1 }
  let(:record1) { store.records.new tid: 'test', rowid: '1', data: {name: 'A'} }
  let(:record2) { store.records.new tid: 'test', rowid: '2', data: {name: 'B'} }
  let(:record3) { store.records.new tid: 'test', rowid: '3', data: {name: 'C'} }

  let(:deltas) do
    [
     Dropbox::Delta.new(rev: 1, changes: [Dropbox::RecordChanges::Create.new(record: record1)]),
     Dropbox::Delta.new(rev: 2, changes: [Dropbox::RecordChanges::Create.new(record: record2)]),
     Dropbox::Delta.new(rev: 3, changes: [Dropbox::RecordChanges::Create.new(record: record3)])
    ]
  end

  before do
    mock(sync.dropbox.deltas).all { deltas }
  end

  subject { sync }

  describe '#fetch_remote_deltas' do
    before do
      mock(sync).store_delta_if_not_exist(deltas[0])
      mock(sync).store_delta_if_not_exist(deltas[1])
      mock(sync).store_delta_if_not_exist(deltas[2])
      sync.fetch_remote_deltas
    end
    subject { sync }
    its(:remote_rev) { should == 3 }
  end

  describe '#store_delta_if_not_exist' do

  end

end
