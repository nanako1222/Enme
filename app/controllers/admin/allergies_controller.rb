class Admin::AllergiesController < ApplicationController
  before_action :authenticate_admin!

  def index
    @allergy = Allergy.new
    @allergies = Allergy.all.order(id: "DESC").page(params[:page]).per(10)
  end

  def create
    @allergy = Allergy.new(allergy_params)
    if @allergy.save
      redirect_to admin_allergies_path, notice: 'アレルゲンの追加に成功しました'
    else
     redirect_to  admin_allergies_path, alert:  'アレルゲンの追加に失敗しました'
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
      flash.now[:alert] =  '登録に失敗しました'
      render :edit
    end
  end

  def destroy
    @allergen = Allergy.find(params[:id])
    if @allergen.destroy
      redirect_to admin_allergies_path, alert: 'アレルゲンを削除しました'
    end
  end

    private
    def allergy_params
      params.require(:allergy).permit(:allergen)
    end
end
