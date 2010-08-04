class InvolvementsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :show]

  auto_actions_for :presentation, [:new, :create]

end
