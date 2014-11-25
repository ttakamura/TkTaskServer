# -*- coding: utf-8 -*-
class Dropbox
  class DataStore < Resource
    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer

    def self.default
      self.all.find{ |d| d.dsid == 'default' }
    end

    def self.all
      Dropbox::Api.list_datastores[:datastores]
    end

    def records
      data_store = self
      @records ||= Class.new(Record) do
        define_singleton_method(:data_store) { data_store }
      end
    end

    def deltas
      data_store = self
      @deltas ||= Class.new(Delta) do
        define_singleton_method(:data_store) { data_store }
      end
    end
  end
end
