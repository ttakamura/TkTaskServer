# -*- coding: utf-8 -*-
class Dropbox::Sync
  attr_reader :db, :remote_rev

  def initialize
    @db = DB::Delta.new(DB.open(path: 'deltas'), data_store.deltas)
    @remote_rev = nil
  end

  def data_store
    self.class.data_store || Dropbox::DataStore.default
  end

  def sync!
    push_local_deltas
    fetch_remote_deltas
  end

  # TODO: 差分取得
  def fetch_remote_deltas
    data_store.deltas.all.each do |delta|
      @remote_rev = delta.rev
      @db.put_delta_if_not_exist delta.rev, delta
    end
  end

  def push_local_deltas
    # TODO: push all local changes
  end
end
