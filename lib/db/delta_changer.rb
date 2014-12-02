# -*- coding: utf-8 -*-
module DB::DeltaChanger
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
