# -*- coding: utf-8 -*-
class DB::Delta
  module Change
    def watch &observer
      @observers << observer
    end

    def notify_change record
      @observers.each{ |obs| obs.call record }
    end

    def apply_change delta
      delta.changes.each do |change|
        rowid  = change.record.rowid
        record = change.apply record_db[rowid]
        record_db[rowid] = record
        notify_change record
      end
    end

    def rebuild!
      record_db.clear!
      each do |rev, delta|
        apply_change delta
      end
    end
  end

  include Change
  include DB::Base::Serializer
  extend Forwardable

  attr_reader :record_db, :delta_klass
  def_delegators :@db, :[], :get, :[]=, :put, :delete, :includes?, :keys, :values, :each, :clear!

  def initialize delta_db, record_db, delta_klass=Dropbox::Delta
    @db            = delta_db
    @db.serializer = self
    @record_db     = record_db
    @delta_klass   = delta_klass
    @observers     = []
  end

  def current_rev
    db.keys.sort.last
  end

  def put_delta_if_not_exist rev, delta
    unless includes?(rev)
      self[rev] = delta
      apply_change delta
    end
  end

  def to_value delta
    super delta.pack
  end

  def from_value db_value
    return nil unless db_value
    delta_klass.unpack super(db_value)
  end

  def to_key rev
    super("%010d" % rev)
  end

  def from_key key
    super(key).to_i
  end

  private
  def db
    @db
  end
end
