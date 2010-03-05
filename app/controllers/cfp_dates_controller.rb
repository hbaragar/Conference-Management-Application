class CfpDatesController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :write_only

end
