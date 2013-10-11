class ConferencesController < ApplicationController

  before_filter :login_required, :except => :for_confero

  hobo_model_controller

  auto_actions :all

  show_action :participants
  show_action :participants_with_conflicts
  show_action :rooms_with_conflicts
  show_action :roomless_sessions
  show_action :schedule
  show_action :manage_colocated_conferences
  show_action :reorder_portfolios
  show_action :committee_email_lists
  show_action :for_confero

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

  def participants_with_conflicts
    hobo_show do
      @conference.participants.*.set_conflicted!
      hobo_index @conference.participants.conflicted
    end
  end

  def rooms_with_conflicts
    hobo_show do
      @conference.rooms.*.set_conflicted!
      hobo_index @conference.rooms.conflicted
    end
  end

  def for_confero
    hobo_show do |format|
      format.json { render :json => @conference.for_confero }
    end
  end

end
