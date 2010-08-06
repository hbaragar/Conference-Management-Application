class ConferencesController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :all

  show_action :participants

  def index
    hobo_index Conference.host_conferences.apply_scopes(
      :search	=> [params[:search], :name],
      :order_by	=> parse_sort_param(:name)
    )
  end

  def show
    @conference = find_instance
    @portfolios = @conference.portfolios.apply_scopes(
      :search	=> [params[:search], :name],
      :order_by	=> parse_sort_param(:name)
    )
  end

  def participants
    hobo_show do
      hobo_index @conference.participants.apply_scopes(
	:search	=> [params[:search], :name, :affiliation, :country],
	:order_by	=> parse_sort_param(:name, :affiliation)
      )
    end
  end

end
