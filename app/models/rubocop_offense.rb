# == Schema Information
#
# Table name: rubocop_offenses
#
#  id              :integer          not null, primary key
#  severity        :string(255)      not null
#  message         :text
#  cop_name        :string(255)
#  location_line   :integer
#  location_column :integer
#  location_length :integer
#  source_file_id  :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class RubocopOffense < ActiveRecord::Base
  validates_presence_of :message, :cop_name, :severity
  belongs_to :source_file
  has_one :project, through: :source_file

  def github_link
    project = source_file.project
    "https://github.com/" + [
      project.username,
      project.name,
      "blob",
      project.default_branch, # TODO Replace branch with commit
      source_file.path,
    ].join('/') + "#L#{location_line}"
  end

  def to_html
    code_lines = CodeRay.scan(code_snippet, :ruby).div(
      line_numbers: :inline,
      line_number_start: line_number_start,
      highlight_lines: [location_line],
      line_number_anchors: false,
    ).lines
    code_lines.push(highlight_line).join
  end

  # Returns a range that contains the location_line and some context.
  # @return [Range]
  def line_range
    max_lines = source_file.content.lines.size - 1
    context_lines = 3
    first_line = [0, location_line - context_lines - 1].max
    last_line = [max_lines, location_line + context_lines - 1].min
    first_line..last_line
  end

  private

  def code_snippet
    source_file.content.lines[line_range].join
  end

  def highlight_line
    i = (location_line - line_number_start + 1)
    "<span class='highlighted-line offset-#{i}'></span>"
  end

  def line_number_start
    num = location_line - 3
    [1, num].max
  end

  class << self
    def order_by_severity
      query = %Q[
        case #{table_name}.severity
          when 'convention' then 5
          when 'warning'    then 4
          when 'refactor'   then 3
          when 'error'      then 2
          when 'fatal'      then 1
          else 99
        end
      ].strip
      order(query)
    end
  end
end
