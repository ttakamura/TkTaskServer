# -*- coding: utf-8 -*-
class Dropbox::Sync
  attr_reader :delta_db, :remote_rev

  def initialize delta_db
    @delta_db   = delta_db
    @remote_rev = data_store.rev
  end

  def local_rev
    delta_db.current_rev || 0
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
    data_store.deltas.all(local_rev+1).each do |delta|
      @remote_rev = delta.rev
      delta_db.put_delta_if_not_exist delta.rev, delta
    end
  end

  def push_local_deltas
    # TODO: push all local changes
  end

  def push_local_delta delta
    delta.save!
  end
end
