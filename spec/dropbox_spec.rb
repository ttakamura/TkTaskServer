require 'spec_helper'

describe Dropbox, vcr: {cassette_name: 'dropbox_api'} do
  subject { Dropbox }

  its(:connection) { should be_a Dropbox::Connection }
end
