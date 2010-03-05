class ConferencesController < ApplicationController

  before_filter :login_required

  hobo_model_controller

  auto_actions :all

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

end
