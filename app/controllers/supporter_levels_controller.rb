class SupporterLevelsController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :all, :except => [:index, :show, :new]

end
