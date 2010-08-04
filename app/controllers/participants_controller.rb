class ParticipantsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  autocomplete

  def index
    hobo_index Participant.apply_scopes(
      :search	=> [params[:search], :name, :affiliation, :country],
      :order_by	=> parse_sort_param(:name, :affiliation)
    )
  end

end
