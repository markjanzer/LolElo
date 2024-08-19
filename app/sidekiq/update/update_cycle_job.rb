class Update::UpdateCycleJob
  include Sidekiq::Job

  def perform
    Updater.call
    ModelUpdater.call
    EloSnapshots::Creator.call
  end
end
