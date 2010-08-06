class ParticipantsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  autocomplete

end
