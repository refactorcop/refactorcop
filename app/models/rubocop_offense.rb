class RubocopOffense < ActiveRecord::Base
  validates_presence_of :message, :cop_name, :severity
  belongs_to :source_file
end
