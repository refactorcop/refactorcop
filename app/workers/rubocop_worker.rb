require 'zip'

class RubocopWorker
  include Sidekiq::Worker

  sidekiq_options retry: true

  #start rubocop for a given repo
  def perform(project_id, force_run: false)

    project = Project.find(project_id)

    #exit if the project is not existing
    if project.nil?
      Rails.logger.warning "Project ##{project_id} not found!"
      return nil
    end

    #check wether the project is updated since last run
    if !project.new_commits? && !force_run
      Rails.logger.info "Project ##{project_id} #{project.full_name} hasn't been updated, *noop*"
      return nil
    end

    Rails.logger.info "Project ##{project_id} #{project.full_name} fetching project zipfile"

    #grab the repo
    #wget project.clone_url + ".zip"
    Tempfile.create(["#{project.username}-#{project.name}",".zip"], :encoding => 'ascii-8bit') do |file|

      dl_req = HTTPClient.get_content(project.download_zip_url) do |chunk|
        file.write(chunk)
      end

      #unzip the file
      Zip::File.open_buffer(file) do |zip_file|
        # Handle entries one by one
        zip_file.each do |entry|
          # Extract to file/directory/symlink
          puts "Extracting #{entry.name}"
          #entry.extract(dest_file)

          # Read into memory
          #content = entry.get_input_stream.read
        end

        # Find specific entry
        #entry = zip_file.glob('*.csv').first
        #puts entry.get_input_stream.read
      end

    end

    #run rubocop

    #capture json output

    #process json output

  end
end
