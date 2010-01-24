class PortfoliosController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index

  auto_actions_for :conference, [:new, :create]

  def show
    @portfolio = find_instance
    @members = @portfolio.members.apply_scopes(
      :search	=> [params[:search], :name, :chair, :affiliation],
      :order_by	=> parse_sort_param(:name, :chair, :affiliation)
    )
 end

end
