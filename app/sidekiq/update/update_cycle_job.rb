class Update::UpdateCycleJob
  include Sidekiq::Job

  def perform(serie_id)
    Updater.call
    ModelUpdater.call
    EloSnapshots::Creator.call
  end
end
