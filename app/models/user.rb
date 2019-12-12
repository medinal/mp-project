require 'faraday'
require 'json'

class User < ApplicationRecord
  def set_access_token(code)
    url = 'https://www.strava.com/oauth/token?' \
      "client_id=#{ENV['STRAVA_CLIENT_ID']}&" \
      "client_secret=#{ENV['STRAVA_SECRET']}&" \
      "code=#{code}&" \
      'grant_type=authorization_code'
    resp = Faraday.post(url)
    data = JSON.parse(resp.body)
    update_attributes(
      expires_at: data['expires_at'],
      refresh_token: data['refresh_token'],
      access_token: data['access_token']
    )
  end

  def update_access_token
    url = 'https://www.strava.com/oauth/token?' \
      "client_id=#{ENV['STRAVA_CLIENT_ID']}&" \
      "client_secret=#{ENV['STRAVA_SECRET']}&" \
      "refresh_token=#{refresh_token}&" \
      'grant_type=refresh_token'
    resp = Faraday.post(url)
    data = JSON.parse(resp.body)
    update_attributes(
      expires_at: data['expires_at'],
      refresh_token: data['refresh_token'],
      access_token: data['access_token']
    )
  end

  def valid_token?
    expires_at + 1800000 < Time.now.to_i
  end
end
