# -*- coding: utf-8 -*-
require File.expand_path("../../lib/dropbox.rb", __FILE__)
Dir[File.expand_path("./support/**/*.rb", __FILE__)].each {|f| require f}

require 'rspec/its'
require 'vcr'

RSpec.configure do |config|
  config.mock_with :rr

  # config.include Paperclip::Shoulda::Matchers
  # config.include Capybara::DSL, :type => :request
  # config.include Capybara::RSpecMatchers, :type => :request
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
