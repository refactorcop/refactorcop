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

  # Returns a range that contains the location_line and some context.
  # @return [Range]
  def line_range
    max_lines = source_file.content.lines.size - 1
    context_lines = 3
    a = [0, location_line - context_lines - 1].max
    b = [max_lines, location_line + context_lines - 1].min
    a..b
  end

  def to_html
    lines = self.source_file.content.lines[self.line_range]
    codelines = CodeRay.scan(lines.join, :ruby).div({
      line_numbers: :inline,
      line_number_start: line_number_start,
      highlight_lines: [self.location_line],
      line_number_anchors: false
    }).lines

    style = "background-color: rgba(255, 0, 0, 0.15); min-width: 100%; display: block;"
    style = ""

    highlight_line + codelines[ 0 .. 3 ].join + "<span style=\"#{style}\">" + codelines[ 4 ] + "</span>" + codelines[ 5 .. -1 ].join
  end

  def highlight_line
    top = "#{(location_line - line_number_start + 1)* 18 - 6}px"
    "<span style='background: rgba(255, 122, 14, 0.25); width: 100%; position: absolute; top: #{top}; display: block; height: 18px;'></span>"
  end
  private :highlight_line

  def line_number_start
    num = location_line - 3
    if num <= 0
      1
    else
      num
    end
  end
  private :line_number_start

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
end
