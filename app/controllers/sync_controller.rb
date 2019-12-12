# frozen_string_literal: true
class SyncController < ApplicationController
  def subscription_callback
    verify_token = ENV['VERIFY_TOKEN']
    mode = params['hub.mode']
    token = params['hub.verify_token']
    challenge = params['hub.challenge']
    if mode && token && mode == "subscribe" &&
        token == verify_token
      render status: 200, json: { 'hub.challenge' => challenge }
    else
      render status: 403
    end
  end

  def sync_activity
    if valid_hook?
      SyncActivityJob.perform_async(params[:object_id], params[:owner_id])
    end

    render status:200, json: {}
  end

  private

  def valid_hook?
    params[:object_type] == 'activity' &&
      params[:aspect_type] != 'delete'
  end
end
