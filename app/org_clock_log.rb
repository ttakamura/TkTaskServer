class OrgClockLog
  attr_reader :start_time, :end_time

  def initialize text
    range = parse_range(text)
    @start_time = Time.parse(range[:start_time]) if range[:start_time]
    @end_time   = Time.parse(range[:end_time])   if range[:end_time]
  end

  private
  def parse_range text
    # [2014-12-31 Wed 05:44]--[2014-12-31 Wed 06:52] =>  1:08
    if m = text.match(/\[(.+?)\](--\[(.+?)\])?(\s+=>\s+(.+?))?$/)
      all, begin_time, sep, end_time, sep2, span = m.to_a
      {start_time: begin_time, end_time: end_time}
    end
  end
end
