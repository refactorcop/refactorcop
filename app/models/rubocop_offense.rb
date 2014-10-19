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

  def line_range
    max_lines = source_file.content.lines.size - 1
    context_lines = 3
    a = [0, location_line - context_lines - 1].max
    b = [max_lines, location_line + context_lines].min
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
    
    codelines[ 0 .. 3 ].join + "<span style=\"background-color:rgba(255, 0, 0, 0.15);\">" + codelines[ 4 ] + "</span>" + codelines[ 5 .. -1 ].join
  end

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

    #"https://github.com/expectedbehavior/acts_as_archival/blob/05dc4e5d6f621dcc76028d88699e0e7a178ff78c/lib/expected_behavior/acts_as_archival.rb#L2-L8"

    "https://github.com/" + [
      project.username,
      project.name,
      "blob",
      project.default_branch,
      source_file.path,
    ].join('/') + "#L#{location_line}"
  end
end
