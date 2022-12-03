class Admin::CustomersController < ApplicationController
  before_action :authenticate_admin!
  def index
    @customer = Customer.new
    @customers = Customer.all.order(id: "DESC").page(params[:page]).per(10)
  end

  def show
    @customer = Customer.find(params[:id])
    @state = State.find(@customer.state_id).state
    @area = Area.find(@customer.area_id).area
  end

  def edit
    @customer = Customer.find(params[:id])
    @area = Area.where(state_id: @customer.state_id)
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update(customer_params)
      redirect_to admin_customer_path, notice: '顧客情報を編集しました！'
    else
      flash.now[:alert] =  '登録に失敗しました'
      render :edit
    end
  end

  private
  def customer_params
    params.require(:customer).permit(:last_name, :first_name, :first_name_kana, :last_name_kana, :email, :state_id, :area_id, :telephone_number, :is_valid, allergy_ids: [])
  end
end
