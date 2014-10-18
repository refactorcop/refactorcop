class RubocopFileWorker
  include Sidekiq::Worker

  def perform(source_file_id)
    sf = SourceFile.find_by_id!(source_file_id)
    sf.update_offenses
  end
end
