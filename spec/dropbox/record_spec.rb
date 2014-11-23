require 'spec_helper'

describe Dropbox::Record do
  let(:data_store) { Dropbox::DataStore.new handle: 'my_handle', dsid: 'default', rev: 10 }
  let(:record)     { data_store.records.new tid: 'table1', rowid: rowid, data: data }
  let(:rowid)      { '1234' }
  let(:data)       { {name: 'hello', age: 20} }
  let(:api_request){ {} }

  subject { record }

  its(:name) { should == 'hello' }
  its(:age)  { should == 20 }
  its(:tid)  { should == 'table1' }

  describe '#name=' do
    before { record.name = 'world 99' }

    its(:name) { should == 'world 99' }
  end

  describe '#save!' do
    let(:delta) { api_request[:delta] }

    before do
      mock(Dropbox::Api).put_delta.with_any_args do |handle, delta|
        expect(handle).to eq 'my_handle'
        api_request[:delta] = delta
        {rev: 11}
      end
      @response = record.save!
    end

    subject { @response }

    context 'create' do
      let(:rowid) { nil }

      it { should be }

      describe 'delta' do
        subject { delta }

        its(:rev) { should == 11 }

        describe 'change' do
          subject { delta.changes.first }

          it { should be_a Dropbox::RecordChanges::Create }
          its('record.rowid') { should be }
          its('record.name')  { should == 'hello' }
        end
      end
    end

    context 'update' do
      let(:rowid) { '11223344' }

      it { should be }

      describe 'delta' do
        subject { delta }

        its(:rev) { should == 11 }

        describe 'change' do
          subject { delta.changes.first }

          it { should be_a Dropbox::RecordChanges::Update }
          its(:record) { should be_a Dropbox::RecordOperation }
          its('record.rowid') { should == '11223344' }

          describe 'data' do
            subject { delta.changes.first.record.data[:name] }

            it { should be_a Dropbox::RecordFieldOperations::Put }
            its(:value) { should == 'hello' }
          end
        end
      end
    end
  end

  describe '#serialize_data' do
    subject { record.serialize_data }

    its(['name']) { should == 'hello' }
    its(['age'])  { should == {'I' => '20'} }
  end
end
