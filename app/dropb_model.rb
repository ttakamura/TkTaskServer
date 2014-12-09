# -*- coding: utf-8 -*-
class DropbModel
  class << self
    def find rowid
      r = db.records[rowid]
      return nil unless r.tid == table_id
      self.new r
    end

    def all
      db.records.all.find_all{ |r| r.tid == table_id }.map{ |r| self.new r }
    end

    def db= db
      @db = db
    end

    def db
      @db ||= begin
                remote, local = DB.open :default
                local
              end
    end

    def table_id= id
      @table_id = id
    end

    def table_id
      @table_id
    end

    def attribute name
      define_method(name) do
        @record.data[name]
      end

      define_method("#{name}=") do |value|
        @record.send("#{name}=", value)
      end
    end

    def sync!
      db.sync!
    end
  end

  extend Forwardable
  attr_reader :record

  def_delegators :@record, :tid, :rowid

  def initialize record={}
    @record = record.is_a?(Hash) ? db.records.new(tid: self.class.table_id, data: record)
                                 : record
  end

  def save! options={}
    @record.save!    # TODO: local に貯める

    db.records[@record.rowid] = @record

    db.sync! if options[:sync] == true
  end

  def destroy! options={}
    @record.destroy!  # TODO: local に貯める

    db.records.delete @record.rowid

    db.sync! if options[:sync] == true
  end

  private
  def db
    self.class.db
  end
end
