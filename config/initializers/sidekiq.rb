schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

# Mute sidekiq logs in tests
Sidekiq.configure_client do |config|
  config.logger = Rails.env.test? ? Logger.new(nil) : Sidekiq.logger
end