namespace :sidekiq do
  desc "Clear scheduled jobs"
  task clear_scheduled: :environment do
    Sidekiq::Cron::Job.destroy_all!
    Sidekiq::Queue.all.each(&:clear)
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    puts "Cleared all Sidekiq jobs and schedules"
  end
end