# -*- coding: utf-8 -*-
require 'base64'
require 'faraday'
require 'faraday_middleware'
require 'virtus'
require 'pp'

class Dropbox
  APP_KEY      = ENV['DROPB_APP_KEY']
  APP_SECRET   = ENV['DROPB_APP_SECRET']
  ACCESS_TOKEN = ENV['DROPB_TOKEN']
  END_POINT    = 'https://api.dropbox.com'

  class << self
    def connection
      @connection ||= Dropbox::Connection.new ACCESS_TOKEN
    end

    def data_stores
      DataStore.fetch_all
    end
  end
end

require File.expand_path(File.dirname(__FILE__)) + '/dropbox/connection.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/api.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/resource.rb'

class Dropbox
  class Record < Resource
  end
  class RecordOperation < Resource
  end
end

require File.expand_path(File.dirname(__FILE__)) + '/dropbox/data_store_field.rb'
require File.expand_path(File.dirname(__FILE__)) + '/dropbox/data_store.rb'
