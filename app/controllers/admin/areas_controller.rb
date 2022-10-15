class Admin::AreasController < ApplicationController
  def index
    @area = Area.new
    @areas = Area.all.page(params[:page])
  end
  private
    def area_params
      params.require(:area).permit(:area)
    end
end
