class IcalExporter
  def initialize top_org_headline
    @headlines = top_org_headline.headlines
  end

  def calendar
    cal         = Icalendar::Calendar.new
    tz          = TZInfo::Timezone.get 'Asia/Tokyo'
    event_start = DateTime.new 2008, 12, 29, 8, 0, 0
    timezone    = tz.ical_timezone event_start
    cal.add_timezone timezone
    cal
  end
end
