class Admin::AreasController < ApplicationController
  def index
    @state = State.new
    @states = State.all.page(params[:page]).per(10)
  end
  def show
    @state = State.find(params[:id])
    @area = Area.new
    @areas = @state.areas.page(params[:page])
  end
  private
    def area_params
      params.require(:area).permit(:area)
    end
    def state_params
      params.require(:state).permit(:state)
    end
end
