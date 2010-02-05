class MembersController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :show]

  auto_actions_for :portfolio, [:create]

end
