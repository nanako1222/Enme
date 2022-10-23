class AreasController < ApplicationController
  def index
    @areas = Area.where(state_id: params[:state_id])
    @type = params[:type]
    render layout: false
  end
end
