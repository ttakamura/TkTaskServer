require 'spec_helper'

describe Dropbox::Record, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD} do
  let(:data_store) { Dropbox::DataStore.new handle: 'my_handle', dsid: 'default', rev: 10 }
  let(:record)     { data_store.records.new tid: 'table1', rowid: rowid, data: data }
  let(:rowid)      { '1234' }
  let(:data)       { {name: 'hello', age: 20} }

  describe '#save!' do
    subject { record.save! }

    context 'create' do
      let(:rowid) { nil }

      before do
        mock(Dropbox::Api).put_delta.with_any_args do |handle, delta|
          change = delta.changes.first
          expect(handle).to eq 'my_handle'
          expect(delta).to be_a Dropbox::Delta
          expect(change).to be_a Dropbox::RecordChanges::Create
          expect(change.record.rowid).to be
          {rev: 11}
        end
      end

      it { should be }
    end

    context 'update' do
      let(:rowid) { '11223344' }

      before do
        mock.proxy(Dropbox::Api).put_delta('my_handle', anything).once do |rev, delta|
          change = delta.changes.first
          expect(delta).to be_a Dropbox::Delta
          expect(change).to be_a Dropbox::RecordChanges::Update
          expect(change.record.rowid).to eq '11223344'
        end
      end

      it { should be }
    end
  end
end

describe Dropbox::Delta, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD} do

end

describe Dropbox::RecordOperation, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD} do

end
