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
      tags.empty? ? '' : "   :#{tags.join(':')}:"
    end

    def schedule_to_s
      "SCHEDULED: #{ scheduled_at.to_s }"
    end

    def clock_logs_to_s
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
    puts headline.to_s
    puts headline.schedule_to_s
    puts headline.clock_logs_to_s
    puts headline.properties_to_s
    puts headline.body_to_s
  end

  # def print_line line, headline, task
  #   case line.paragraph_type
  #   when :heading1
  #     if task
  #       puts line.to_s.gsub(/(TODO|DONE|WAIT)/, task.done_as_text)
  #     else
  #       puts line.to_s
  #     end
  #
  #   when :metadata
  #     if line.to_s =~ /CLOCK: /
  #     # TODO: Task#clocks ができたら出力して良い
  #     elsif line.to_s =~ /SCHEDULED: /
  #       puts line.to_s
  #
  #       if task && task.elapsed > 0
  #         # CLOCK: [2015-01-04 Sun 08:49]--[2015-01-04 Sun 09:05] =>  0:16
  #         start_at  = parse_metadata_line(line)[:scheduled_date]
  #         end_at    = start_at             + task.elapsed
  #         span_time = Time.new(2014, 1, 1) + task.elapsed
  #         puts "  CLOCK: [#{ start_at.strftime(EMACS_DATE_FORMAT) }]--[#{ end_at.strftime(EMACS_DATE_FORMAT) }] => #{ span_time.strftime("%H:%M") }"
  #       end
  #
  #     else
  #       puts line.to_s
  #     end
  #
  #   else
  #     puts line.to_s
  #   end
  # end
end
