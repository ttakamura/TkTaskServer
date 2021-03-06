# -*- coding: utf-8 -*-
class DropbModel
  class << self
    def find rowid
      r = db.records[rowid]
      return nil unless r
      return nil unless r.tid == table_id
      self.new r
    end

    def find_by conditions
      r = all_records.find{ |x| conditions.each.all?{ |k, v| x.data[k] == v } }
      return nil unless r
      self.new r
    end

    def all
      all_records.map{ |r| self.new r }
    end

    def all_records
      db.records.all.find_all{ |r| r.tid == table_id }
    end

    def db_name= db_name
      @db_name = db_name
    end

    def db
      @db ||= begin
                remote, local = DB.open(@db_name || :default)
                local
              end
    end

    def table_id= id
      @table_id = id
    end

    def table_id
      @table_id
    end

    def attribute name, options={}
      @attributes ||= {}
      @attributes[name] = options.merge({
        name: name,
        index: @attributes.count
      })

      define_method(name) do
        @record.data[name]
      end

      define_method("#{name}=") do |value|
        @record.send("#{name}=", value)
      end
    end

    def each_attribute &block
      @attributes.sort_by{ |k,v| v[:index] }.each(&block)
    end

    def sync!
      db.sync!
    end

    def transaction &block
      block.call
      sync!
    end
  end

  extend Forwardable
  extend TextMapper
  attr_reader :record

  def_delegators :@record, :tid, :rowid

  def initialize record={}
    @record = record.is_a?(Hash) ? db.records.new(tid: self.class.table_id, data: record)
                                 : record
  end

  def save! options={}
    if options[:sync] == true
      @record.save!
      db.sync!
    else
      db.push_local_change @record.to_change
    end
    db.records[@record.rowid] = @record
  end

  def destroy! options={}
    if options[:sync] == true
      @record.destroy!
      db.sync!
    else
      @record.prepare_destroy
      db.push_local_change @record.to_change
    end
    db.records.delete @record.rowid
  end

  private
  def db
    self.class.db
  end
end
