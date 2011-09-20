class ParticipantsController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :conference, [:new, :create]

  autocomplete

end
