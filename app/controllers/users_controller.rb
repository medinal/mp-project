# frozen_string_literal: true
class UsersController < ApplicationController
  def new; end

  def create
    @user = User.new(params.require(:user).permit(:email, :mp_key, :athlete_id))
    @user.save
    redirect_to 'https://www.strava.com/oauth/authorize?' \
      "client_id=#{ENV['STRAVA_CLIENT_ID']}&" \
      "redirect_uri=https://mountain-strava-project.herokuapp.com/users/#{@user.id}/success&" \
      'response_type=code&' \
      'approval_prompt=force&' \
      'scope=activity:read_all,activity:write'
  end

  def success
    @user = User.find(params[:user_id])
    @user.set_access_token(params[:code])
  end
end
