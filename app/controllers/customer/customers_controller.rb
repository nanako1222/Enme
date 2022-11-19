class Customer::CustomersController < ApplicationController
  before_action :authenticate_customer!
  def show
    @customer = current_customer
    @state = State.find(@customer.state_id).state
    @area = Area.find(@customer.area_id).area
  end

  def edit
    @customer = current_customer
    @allergies = Allergy.all
    @area = Area.where(state_id: @customer.state_id)
  end

  def update
    @customer = current_customer
    if @customer.update(customer_params)
      redirect_to customers_my_page_path, notice: 'ユーザー情報の変更に成功しました'
    else
      render :edit
    end
  end

  def confirm
    @customer = current_customer
  end

  def out
    @customer = current_customer
    @customer.update(is_valid: false)
    reset_session
    flash[:notice] = "退会処理を実行いたしました"
    redirect_to root_path
  end

    private
    def customer_params
      params.require(:customer).permit(:last_name, :first_name, :first_name_kana, :last_name_kana, :email, :state_id, :area_id, :telephone_number, allergy_ids: [])
    end

end
