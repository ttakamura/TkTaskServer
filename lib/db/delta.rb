# -*- coding: utf-8 -*-
class DB::Delta
  include DB::DeltaChanger
  include DB::Base::Serializer
  extend Forwardable

  attr_reader :record_db, :delta_klass
  def_delegators :@db, :[], :get, :[]=, :put, :delete, :includes?, :keys, :values, :each, :clear!
  def_delegators :@delta_klass, :new, :bundle

  def initialize delta_db, record_db, delta_klass=Dropbox::Delta
    @db            = delta_db
    @db.serializer = self
    @record_db     = record_db
    @delta_klass   = delta_klass
    @observers     = []
  end

  def all
    to_enum(:each).map{ |key, value| value }
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
