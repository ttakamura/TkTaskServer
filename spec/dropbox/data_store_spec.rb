require 'spec_helper'

describe Dropbox::DataStore, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD} do
  let(:data_store) { Dropbox::DataStore.new dsid: 'test1', handle: 'my_handle', rev: 10 }

  subject { data_store }

  its(:dsid)   { should == 'test1' }
  its(:handle) { should == 'my_handle' }
  its(:rev)    { should == 10 }

  describe '.all' do
    before      { mock(Dropbox::Api).list_datastores { {datastores: [data_store]} } }
    subject     { Dropbox::DataStore.all }
    its(:first) { should == data_store }
  end

  describe '#records' do
    subject { data_store.records }

    its(:ancestors)  { should be_include Dropbox::Record }
    its(:data_store) { should == data_store }
  end

  describe '#deltas' do
    subject { data_store.deltas }

    its(:ancestors)  { should be_include Dropbox::Delta }
    its(:data_store) { should == data_store }
  end
end
