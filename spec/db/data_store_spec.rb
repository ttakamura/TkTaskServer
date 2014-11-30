require 'spec_helper'

describe DB::DataStore do
  let(:local_ds)  { DB::DataStore.new remote_ds, DB::Hash.new, DB::Hash.new }
  let(:remote_ds) { Dropbox::DataStore.new dsid: 'test1', handle: 'my_handle', rev: 1 }
  let(:record1)   { remote_ds.records.new tid: 'test', rowid: '1', data: {name: 'A'} }
  let(:record2)   { remote_ds.records.new tid: 'test', rowid: '2', data: {name: 'B'} }
  let(:record3)   { remote_ds.records.new tid: 'test', rowid: '3', data: {name: 'C'} }

  let(:deltas) do
    [
     Dropbox::Delta.new(rev: 1, changes: [Dropbox::RecordChanges::Create.new(record: record1)]),
     Dropbox::Delta.new(rev: 2, changes: [Dropbox::RecordChanges::Create.new(record: record2)]),
     Dropbox::Delta.new(rev: 3, changes: [Dropbox::RecordChanges::Create.new(record: record3)])
    ]
  end

  before do
    mock(remote_ds.deltas).all(0).any_times { deltas }
    local_ds.sync!
  end

  describe '#deltas' do
    subject { local_ds.deltas }

    its([1]) { should == deltas[0] }
    its([2]) { should == deltas[1] }
  end

  describe '#records' do
    subject { local_ds.records }

    its(['1']) { should == record1 }
    its(['2']) { should == record2 }
  end
end
