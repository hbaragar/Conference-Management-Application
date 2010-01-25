class CfpsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :portfolio, [:new, :create]

end
