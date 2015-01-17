# coding: utf-8
class OrgExporter
  EMACS_DATE_FORMAT = "%Y-%m-%d %a %H:%M"

  def print_line line, headline, task
    case line.paragraph_type
    when :heading1
      if task
        puts line.to_s.gsub(/(TODO|DONE|WAIT)/, task.done_as_text)
      else
        puts line.to_s
      end

    when :metadata
      if line.to_s =~ /CLOCK: /
      # TODO: Task#clocks ができたら出力して良い
      elsif line.to_s =~ /SCHEDULED: /
        puts line.to_s

        if task && task.elapsed > 0
          # CLOCK: [2015-01-04 Sun 08:49]--[2015-01-04 Sun 09:05] =>  0:16
          start_at  = parse_metadata_line(line)[:scheduled_date]
          end_at    = start_at             + task.elapsed
          span_time = Time.new(2014, 1, 1) + task.elapsed
          puts "  CLOCK: [#{ start_at.strftime(EMACS_DATE_FORMAT) }]--[#{ end_at.strftime(EMACS_DATE_FORMAT) }] => #{ span_time.strftime("%H:%M") }"
        end

      else
        puts line.to_s
      end

    else
      puts line.to_s
    end
  end

  def print_headline headline
    task = Task.find_by(id: headline.property_drawer['ID'])

    headline.body_lines.each do |line|
      print_line line, headline, task
    end
  end

  def pull_changes_headline! headline
    # TODO
  end

  def export! file_name
    Task.sync!

    org = parse_org_file file_name

    org.headlines.each do |headline|
      if headline.level == 1
        pull_changes_headline! headline
        print_headline headline
      end
    end
  end
end
