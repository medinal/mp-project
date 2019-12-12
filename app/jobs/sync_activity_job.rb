class SyncActivityJob < ApplicationJob
  include Sidekiq::Worker
  sidekiq_options retry: false

  queue_as :default

  def perform(activity_id, athlete_id)
    ::Sync::Activity.new(activity_id, athlete_id).call
  end
end
