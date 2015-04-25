class Project::ZipFile
  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
    @parsed = false
  end

  def has_rubocop_todos?
    parse_zipfile
    !!@has_rubocop_todos
  end

  # Returns all files with a `.rb` extension
  #
  # @return [Array<Zip::Entry>]
  def ruby_entries
    parse_zipfile
    @ruby_entries
  end

  private

  def parse_zipfile
    return if @parsed
    Zip::File.open_buffer(filepath) do |zf|
      @has_rubocop_todos = zf.glob('**/.rubocop_todo.yml').present?
      @ruby_entries = zf.glob('**/*.rb').compact
    end
    @parsed = true
  end
end
