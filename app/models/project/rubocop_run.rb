class Project::RubocopRun
  DEFAULT_CONFIG_PATH = Rails.root.join('.external_rubocop.yml').freeze

  attr_reader :project, :config_path

  def initialize(project, config_path: nil)
    @config_path = config_path || DEFAULT_CONFIG_PATH
    @project = project
  end

  def run
    project.write_files_to_dir(tmp_dir)
    offenses_json = run_rubocop(tmp_dir)
    offenses_json[:files].each do |files_json|
      process_source_file(files_json)
    end
  ensure
    FileUtils.remove_entry(tmp_dir)
  end

  private

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir
  end

  # Runs Rubocop and returns the result as a Hash (uses json formatter)
  # @return [Hash] offenses
  def run_rubocop(dir)
    output = `cd #{dir}; bundle exec rubocop --config "#{config_path}" -f json`
    MultiJson.load(output, symbolize_keys: true)
  end

  def process_source_file(files_json)
    path = files_json[:path].gsub("#{tmp_dir}/", '')
    source_file = project.source_files.where(path: path).first
    files_json[:offenses].each do |offense_json|
      create_offense(source_file.id, offense_json)
    end
  end

  def create_offense(source_file_id, offense_json)
    RubocopOffense.create(
      source_file_id: source_file_id,
      severity:   offense_json[:severity],
      message:    offense_json[:message],
      cop_name:   offense_json[:cop_name],
      location_column:  offense_json[:location][:column],
      location_line:    offense_json[:location][:line],
      location_length:  offense_json[:location][:length],
    )
  end
end
