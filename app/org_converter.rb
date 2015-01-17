class OrgConverter
  def initialize file_name
    @file_name = file_name
  end

  def parse_tasks
    org   = OrgHeadline.parse_org_file @file_name
    tasks = []

    org.headlines.each do |headline|
      tasks << headline.to_task_attrs
    end

    align_section_rows! tasks

    tasks
  end

  private
  def align_section_rows! tasks
    sections = Hash.new{ |h,k| h[k] = [] }

    tasks.each do |task|
      sections[task[:section]] << task
    end

    sections.each do |sec, children|
      children.each_with_index do |task, index|
        task[:row] = index
      end
    end
  end
end
