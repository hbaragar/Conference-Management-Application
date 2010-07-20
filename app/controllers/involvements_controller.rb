class InvolvementsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]

end
