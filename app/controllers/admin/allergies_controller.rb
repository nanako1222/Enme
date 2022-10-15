class Admin::AllergiesController < ApplicationController
  before_action :authenticate_admin!

  def index
    @allergy = Allergy.new
    @allergies = Allergy.all.page(params[:page])
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
    @allergy = Allergy.find(params[:id])
  end

  def update
    @allergy = Allergy.find(params[:id])
    if @allergy.update(allergy_params)
      redirect_to admin_allergies_path, notice: '編集に成功しました'
    else
      render :edit
    end
  end

    private
    def allergy_params
      params.require(:allergy).permit(:allergen)
    end
end
