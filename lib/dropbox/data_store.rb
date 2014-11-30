# -*- coding: utf-8 -*-
class Dropbox
  class DataStore < Resource
    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer

    class << self
      def [] name
        self.all.find{ |d| d.dsid == name.to_s }
      end

      def default
        self[:default]
      end

      def all
        Dropbox::Api.list_datastores[:datastores]
      end
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

    def syncs
      data_store = self
      @syncs ||= Class.new(Sync) do
        define_singleton_method(:data_store) { data_store }
      end
    end

    def serialize
      attributes
    end
  end
end
