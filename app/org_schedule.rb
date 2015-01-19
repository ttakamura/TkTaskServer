class OrgSchedule
  attr_reader :start_time, :end_time, :repeat_rule

  def initialize scheduled_text
    @text        = scheduled_text
    @start_time  = parse_next_start_time scheduled_text
    @end_time    = parse_next_end_time   scheduled_text
    @repeat_rule = parse_time(scheduled_text)[:repeat]
  end

  private
  def parse_next_start_time text
    time = parse_time text
    Time.parse time[:date] + " " + time[:start_time] if time[:start_time]
  end

  def parse_next_end_time text
    time = parse_time text
    Time.parse time[:date] + " " + time[:end_time]   if time[:end_time]
  end

  def parse_time text
    # <2015-01-17 Sat 14:00-19:40>
    if m = text.match(/^<(\d{4}-\d{2}-\d{2}) .+? ?(\d{2}:\d{2})?(-(\d{2}:\d{2}))? ?(.+)?>$/)
      all, date, start_time, x, end_time, repeat_rule = m.to_a
      {date: date, start_time: start_time, end_time: end_time, repeat: repeat_rule}
    end
  end
end
