require 'spec_helper'

describe Dropbox::Api, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD}  do
  let(:api)    { Dropbox::Api }
  let(:ds)     { Dropbox::DataStore[:default] }
  let(:record) { ds.records.new tid: 'default', rowid: rand.to_s, data: {name: 'hello'} }

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
    context 'create' do
      let(:delta) do
        Dropbox::Delta.new rev: ds.rev, changes: [Dropbox::RecordChanges::Create.new(record: record)]
      end

      before  { @response = api.put_delta(ds.handle, delta) }
      subject { @response }

      its([:rev]) { should be }

      context 'update' do
        before do
          ds.rev += 1
          record.name = 'hello 2'
          delta2 = record.to_delta
          @response = api.put_delta(ds.handle, delta2)
        end

        subject { @response }

        its([:rev]) { should be }
      end
    end
  end
end
