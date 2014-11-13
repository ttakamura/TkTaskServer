require 'spec_helper'

describe Dropbox::Connection, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD} do
  let(:connection) { Dropbox.connection }

  describe '#get' do
    subject { connection.get '/1/datastores/list_datastores' }

    it 'should send a GET request to the Dropbox-API' do
      should be
    end
  end
end
