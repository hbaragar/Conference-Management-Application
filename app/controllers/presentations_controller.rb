class PresentationsController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :portfolio, [:new, :create]
  auto_actions_for :session, [:new, :create]

  web_method :move_higher
  web_method :move_lower

end
