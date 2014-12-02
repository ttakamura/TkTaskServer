class DB::Record
  include DB::Base::Serializer
  extend Forwardable

  attr_reader :record_klass

  def_delegators :@db, :[], :get, :[]=, :put, :delete, :includes?, :each, :keys, :values, :clear!
  def_delegators :@record_klass, :new

  def initialize db, record_klass=Dropbox::Record
    @db            = db
    @db.serializer = self
    @record_klass  = record_klass
  end

  def all
    to_enum(:each).map{ |key, value| value }
  end

  def to_value raw_value
    super raw_value.pack
  end

  def from_value db_value
    return nil unless db_value
    record_klass.unpack super(db_value)
  end

  private
  def db
    @db
  end
end
