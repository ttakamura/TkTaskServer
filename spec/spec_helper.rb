# -*- coding: utf-8 -*-
require 'rspec/its'
require 'vcr'
require 'webmock'

Dir[File.expand_path("./support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr

  # config.include Paperclip::Shoulda::Matchers
  # config.include Capybara::DSL, :type => :request
  # config.include Capybara::RSpecMatchers, :type => :request
end

ENV['DROPB_APP_KEY']    = 'DUMMY_DROPB_APP_KEY'
ENV['DROPB_APP_SECRET'] = 'DUMMY_DROPB_APP_SECRET'
ENV['DROPB_API_LOG']    = 'false'

RECORDING_VCR = !!ENV['RECORD_VCR']
VCR_RECORD = RECORDING_VCR ? :all : :none

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = RECORDING_VCR
end

unless RECORDING_VCR
  WebMock.disable_net_connect!
  ENV['DROPB_TOKEN'] = 'DUMMY_DROPB_TOKEN'
end

require File.expand_path("../../lib/dropbox.rb", __FILE__)
