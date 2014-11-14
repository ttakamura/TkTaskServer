require 'spec_helper'

describe Dropbox::Api, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD}  do
  let(:api)    { Dropbox::Api }
  let(:ds)     { api.list_datastores[:datastores].first }
  let(:record) { Dropbox::Record.new tid: 'default', rowid: rand.to_s, data: {name: 'hello'} }

  describe '#list_datastores' do
    subject { api.list_datastores[:datastores] }

    its(:first) { should be_a Dropbox::DataStore }
  end

  describe '#get_snapshot' do
    subject { api.get_snapshot(ds.handle)[:rows] }

    its(:first) { should be_a Dropbox::Record }
  end

  describe '#get_deltas' do
    subject { api.get_deltas(ds.handle, 0)[:deltas] }

    its(:first) { should be_a Dropbox::Delta }
  end

  describe '#put_delta' do
    let(:delta) { Dropbox::Delta.new rev: ds.rev, changes: [Dropbox::RecordChanges::Create.new(record: record)] }

    subject { api.put_delta(ds.handle, delta) }

    its([:rev]) { should be }
  end
end
