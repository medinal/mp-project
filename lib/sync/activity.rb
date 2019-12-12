# frozen_string_literal: true

require 'strava-ruby-client'

module Sync
  class Activity
    def initialize(activity_id, athlete_id)
      @activity_id = activity_id
      @user = User.where(athlete_id: athlete_id).first
    end

    def call
      @user.update_access_token unless @user.valid_token?

      activity = strava_client.activity(@activity_id)

      return unless activity.type == 'RockClimbing'

      ticks = ::MountainProject::Client.get_ticks(@user.email, @user.mp_key)

      ticks.select! do |tick|
        same_day?(Time.parse(tick['date']), activity.start_date_local)
      end

      return if ticks.empty?

      route_ids = ticks.map { |tick| tick['routeId'] }.join(',')
      routes = ::MountainProject::Client.get_routes(route_ids, @user.mp_key)

      description = create_description(ticks, routes)

      strava_client.update_activity(id: activity.id, description: description)
    end

    private

    def same_day?(d1, d2)
      d1.to_date === d2.to_date
    end

    def create_description(ticks, routes)
      sorted = {
        'Flashed' => [],
        'Sent' => [],
        'Attempted' => [],
        'Lead' => [],
        'Followed' => [],
        'Top-Roped' => [],
        'Soloed' => []
      }

      ticks.each do |tick|
        route = routes.select { |route| route['id'] == tick['routeId'] }.first
        case tick['style']
        when 'Flash' then sorted['Flashed'].push("#{route['name']} (#{route['rating']})")
        when 'Send' then sorted['Sent'].push("#{route['name']} (#{route['rating']})")
        when 'Attempt' then sorted['Attempted'].push("#{route['name']} (#{route['rating']})")
        when 'Lead' then sorted['Lead'].push("#{route['name']} (#{route['rating']})")
        when 'Follow' then sorted['Followed'].push("#{route['name']} (#{route['rating']})")
        when 'TR' then sorted['Top-Roped'].push("#{route['name']} (#{route['rating']})")
        when 'Solo' then sorted['Soloed'].push("#{route['name']} (#{route['rating']})")
        end
      end

      description = ''

      sorted.each do |k, v|
        description += "#{k}: #{v.join(', ')}\n" unless v.empty?
      end

      description
    end

    def strava_client
      @strava_client ||= ::Strava::Api::Client.new(access_token: @user.access_token)
    end
  end
end
