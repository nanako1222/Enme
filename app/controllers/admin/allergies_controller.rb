class Admin::AllergiesController < ApplicationController
  before_action :authenticate_admin!

  def index
  end

  def create
    @allergy = Allergy.new(allergy_params)
    if @allergy.save
      redirect_to admin_allergies_path(@allergy.id), notice: 'アレルゲンの追加に成功しました'
    else
      render :index
    end
  end

  def edit
  end

  def update
  end

    private
    def allergy_params
      params.require(:allergy).permit(:allergen)
    end
end
