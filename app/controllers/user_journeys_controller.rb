class UserJourneysController < ApplicationController
  before_action :require_user

  def show
    @user_journey = current_user.user_journeys.find(params[:id])
    @user_step_by_steps = @user_journey.user_steps.index_by { |user_step| user_step.step }
    @next_step = @user_journey.journey.steps.order(:position).first
  end

  def start
    journey = Journey.find_by!(slug: params[:id])
    step = journey.steps.find_by!(slug: params[:step]) if params[:step]
    user_journey = CreateUserJourney.call(current_user, journey, step).result

    redirect_to user_journey
  end
end
