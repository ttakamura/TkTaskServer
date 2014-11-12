require './lib/dropbox.rb'

store = Dropbox.data_stores.first

MyRecord = store.records

# MyRecord.fetch_all.each do |record|
#   pp record
# end

last_rev = 0

MyDelta = store.deltas

MyDelta.fetch_all.each do |delta|
  # pp delta
  last_rev = delta.rev if delta.rev > last_rev
end

record = Dropbox::Record.new tid: 'test', rowid: 'myrecord', data: {name: 'hoge', age: 22, gender: 'male'}
change = Dropbox::RecordChanges::Create.new(record: record)
new_delta = MyDelta.new rev: last_rev+1, changes: [change]

MyDelta.create(new_delta)
