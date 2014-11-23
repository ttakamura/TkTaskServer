class DB::Base
  include Enumerable
  attr_reader :options, :db

  def initialize options={}
    @options = options
    @db = open
  end

  def open
    raise "Please override this method"
  end

  def [] key
    from_value @db[to_key(key)]
  end
  alias get []

  def []= key, value
    @db[to_key(key)] = to_value(value)
  end
  alias put []=

  def delete key
    @db.delete to_key(key)
  end

  def includes? key
    @db.includes? to_key(key)
  end

  def each options={}
    Enumerator.new do |y|
      inner_each(options) do |k, v|
        y << [from_key(k), from_value(v)]
      end
    end
  end

  def inner_each options={}
    @db.each(options) do |k, v|
      yield k, v
    end
  end

  def keys
    @db.keys.map{ |k| from_key(k) }
  end

  def values
    @db.values.map{ |v| from_value(v) }
  end

  # -- convert key -----------------
  def to_key raw_key
    "db::#{raw_key.to_s}"
  end

  def from_key db_key
    db_key.split("::").last
  end

  # -- convert value ---------------
  def to_value raw_value
    {'v' => raw_value}.to_json
  end

  def from_value db_value
    return nil unless db_value
    JSON.parse(db_value)['v']
  end
end

class DB::Hash < DB::Base
  def open
    Hash.new
  end

  def includes? key
    @db.include? to_key(key)
  end

  def inner_each options={}
    @db.each do |k, v|
      yield k, v
    end
  end
end
