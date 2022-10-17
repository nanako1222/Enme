class AreasController < ApplicationController
  def index
    @areas = Area.where(state_id: params[:state_id])
    render layout: false
  end
end
