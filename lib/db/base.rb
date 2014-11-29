# -*- coding: utf-8 -*-
class DB::Base
  module Serializer
    def to_key raw_key
      "db::#{raw_key.to_s}"
    end

    def from_key db_key
      db_key.split("::").last
    end

    def to_value raw_value
      {'v' => raw_value}.to_json
    end

    def from_value db_value
      return nil unless db_value
      JSON.parse(db_value)['v']
    end
  end

  include Enumerable
  include Serializer
  attr_reader :options, :db
  attr_accessor :serializer

  def initialize options={}
    @options = options
    @serializer = options[:serializer] || self
    @db = open
  end

  def [] key
    serializer.from_value @db[serializer.to_key(key)]
  end
  alias get []

  def []= key, value
    @db[serializer.to_key(key)] = serializer.to_value(value)
  end
  alias put []=

  def delete key
    @db.delete serializer.to_key(key)
  end

  def includes? key
    @db.includes? serializer.to_key(key)
  end

  def each options={}, &block
    enum = Enumerator.new do |y|
      inner_each(options) do |k, v|
        y << [serializer.from_key(k), serializer.from_value(v)]
      end
    end

    if block_given?
      enum.map(&block)
    else
      enum
    end
  end

  def keys
    @db.keys.map{ |k| serializer.from_key(k) }
  end

  def values
    @db.values.map{ |v| serializer.from_value(v) }
  end

  def clear!
    # TODO: 削除する
  end

  private
  def open
    raise "Please override this method"
  end

  def inner_each options={}
    @db.each(options) do |k, v|
      yield k, v
    end
  end
end

class DB::Hash < DB::Base
  def open
    Hash.new
  end

  def includes? key
    @db.include? serializer.to_key(key)
  end

  def inner_each options={}
    @db.each do |k, v|
      yield k, v
    end
  end
end
