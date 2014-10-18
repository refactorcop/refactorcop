class RubocopFileWorker
  include Sidekiq::Worker

  def perform(source_file_id)
    sf = SourceFile.find_by_id!(source_file_id)
    Tempfile.open(['lol', '.rb']) do |f|
      f.write(sf.content.encode('utf-8'))
      json_data = `bundle exec rubocop --config ".rubocop.yml" -f json "#{f.path}"`
      sf.rubocop_offenses = json_data
    end
    sf.save!
  end
end
