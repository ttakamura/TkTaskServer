require 'spec_helper'

describe Dropbox::Sync, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD}  do
  let(:record_db) { DB::Record.new DB::Hash.new }
  let(:delta_db)  { DB::Delta.new DB::Hash.new, record_db }
  let(:sync)      { Dropbox::DataStore.default.syncs.new delta_db }
  let(:store)     { Dropbox::DataStore.new dsid: 'test1', handle: 'my_handle', rev: 1 }
  let(:record1)   { store.records.new tid: 'test', rowid: '1', data: {name: 'A'} }
  let(:record2)   { store.records.new tid: 'test', rowid: '2', data: {name: 'B'} }
  let(:record3)   { store.records.new tid: 'test', rowid: '3', data: {name: 'C'} }
  let(:begin_rev) { 0 }

  let(:deltas) do
    [
     Dropbox::Delta.new(rev: 1, changes: [Dropbox::RecordChanges::Create.new(record: record1)]),
     Dropbox::Delta.new(rev: 2, changes: [Dropbox::RecordChanges::Create.new(record: record2)]),
     Dropbox::Delta.new(rev: 3, changes: [Dropbox::RecordChanges::Create.new(record: record3)])
    ]
  end

  describe '#fetch_remote_deltas' do
    subject { sync }

    context 'current_rev is 0' do
      before do
        mock(sync.data_store.deltas).all(1).any_times { deltas }

        mock.proxy(sync.delta_db).put_delta_if_not_exist(1, deltas[0]).once
        mock.proxy(sync.delta_db).put_delta_if_not_exist(2, deltas[1]).once
        mock.proxy(sync.delta_db).put_delta_if_not_exist(3, deltas[2]).once

        expect(sync.local_rev).to eq 0
        sync.fetch_remote_deltas
      end

      its(:remote_rev) { should == 3 }
      its(:local_rev)  { should == 3 }
    end

    context 'current_rev = 2' do
      before do
        sync.delta_db.put_delta_if_not_exist 1, deltas[0]
        sync.delta_db.put_delta_if_not_exist 2, deltas[1]

        mock(sync.data_store.deltas).all(3).any_times { [deltas[2]] }

        mock.proxy(sync.delta_db).put_delta_if_not_exist(1, deltas[0]).never
        mock.proxy(sync.delta_db).put_delta_if_not_exist(2, deltas[1]).never
        mock.proxy(sync.delta_db).put_delta_if_not_exist(3, deltas[2]).once

        expect(sync.local_rev).to eq 2
        sync.fetch_remote_deltas
      end

      its(:remote_rev) { should == 3 }
      its(:local_rev)  { should == 3 }
    end
  end
end
