# coding: utf-8
class OrgExporter
  module SerializeOrgHeadline
    def to_s
      "#{'*' * level} #{state_to_s}#{title}#{tags_to_s}"
    end

    def state_to_s
      state ? state + ' ' : ''
    end

    def tags_to_s
      text = tags.empty? ? '' : ":#{tags.join(':')}:"
      sep  = " " * (65 - title.length)
      sep + text
    end

    def schedule_to_s
      "SCHEDULED: #{ scheduled_at.to_s }"
    end

    def clock_logs_to_s
      return "" if clock_logs.empty?
      text = []
      text << ':LOGBOOK:'
      clock_logs.map do |l|
        text << "CLOCK: #{ l.to_s }"
      end
      text << ':END:'
      text.join("\n")
    end

    def properties_to_s
      text = []
      text << ':PROPERTIES:'
      properties.each do |key, value|
        sep_length = (9 - key.length)
        separator = ' ' * (sep_length < 1 ? 1 : sep_length)
        text << ":#{key}:#{separator}#{value}"
      end
      text << ':END:'
      text.join("\n")
    end

    def body_to_s
      body_lines.map do |line|
        line.to_s
      end.join("\n")
    end
  end

  EMACS_DATE_FORMAT = "%Y-%m-%d %a %H:%M"

  def initialize
  end

  def print_headline headline
    # task = Task.find_by(id: headline.id)
    print_text headline.to_s,            0
    print_text headline.schedule_to_s,   headline.level
    print_text headline.clock_logs_to_s, headline.level
    print_text headline.properties_to_s, headline.level
    print_text headline.body_to_s,       0
  end

  def print_text text, level
    text.split("\n").each do |line|
      print_line line, level
    end
  end

  def print_line line, level=1
    puts "#{ '  ' * level }#{ line }"
  end
end
