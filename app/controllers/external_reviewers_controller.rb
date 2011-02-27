class ExternalReviewersController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :all, :except => [:index, :show]

  auto_actions_for :cfp, [:create]

end
