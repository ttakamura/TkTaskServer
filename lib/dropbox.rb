# -*- coding: utf-8 -*-
require 'base64'
require 'faraday'
require 'faraday_middleware'
require 'virtus'
require 'json'
require 'pp'
require 'digest'

class Dropbox
  APP_KEY      = Setting.dropbox.app_key
  APP_SECRET   = Setting.dropbox.app_secret
  ACCESS_TOKEN = Setting.dropbox.access_token
  API_LOGGING  = Setting.dropbox.api_logging
  END_POINT    = 'https://api.dropbox.com'

  class << self
    def connection
      @connection ||= Dropbox::Connection.new ACCESS_TOKEN
    end
  end
end

require File.expand_path(File.dirname(__FILE__)) + '/dropbox/connection.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/api.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/resource.rb'

class Dropbox
  class Record < Resource; end
  class RecordOperation < Resource; end
end

require File.expand_path(File.dirname(__FILE__)) + '/dropbox/record_field.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/data_store.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/record.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/delta.rb'
