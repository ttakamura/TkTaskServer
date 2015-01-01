# -*- coding: utf-8 -*-
module TextMapper
  def to_table_text records
    rows = records.map{ |r| to_table_row(r) }

    Hirb::Helpers::AutoTable.render(rows, headers: to_table_header, description: false).to_s
  end

  private
  def to_table_header
    self.each_attribute.map do |k, v|
      if v[:render] != false
        v[:name].to_s
      end
    end.compact
  end

  def to_table_row record
    self.each_attribute.map do |k, v|
      if v[:render] != false
        record.send(k)
      end
    end.compact
  end
end
