require 'rails_helper'

# RSpec.describe Customer, type: :model do
#   it "姓、名を登録すると、姓名が取得できること"
#   # customer = Customer.new(
#   #         last_name:  "桃",
#   #         first_name: "太郎"
#   # )
#   # expect(customer.full_name).to eq "桃 太郎"
# end


RSpec.describe 'Customerモデルのテスト', type: :model do
  describe '各種情報のバリデーションができるかテスト' do
    subject { customer.valid? }

    let!(:other_customer) { build(:customer) }
    let(:customer) { build(:customer) }

    context 'カラムチェック' do
      it '性が空欄でないこと' do
        customer.first_name = ''
        is_expected.to eq false
      end
      it '名が空欄でないこと' do
        customer.last_name = ''
        is_expected.to eq false
      end
      it '性(カナ)が空欄でないこと' do
        customer.first_name_kana = ''
        is_expected.to eq false
      end
      it '名(カナ)が空欄でないこと' do
        customer.last_name_kana = ''
        is_expected.to eq false
      end
      it '電話番号が空欄でないこと' do
        customer.telephone_number = ''
        is_expected.to eq false
      end
      it '都道府県が空欄でないこと' do
        customer.state_id = ''
        is_expected.to eq false
      end
      it '地域エリアが空欄でないこと' do
        customer.area_id = ''
        is_expected.to eq false
      end
      it 'メールアドレスが空欄でないこと' do
        customer.email = ''
        is_expected.to eq false
      end
      it 'パスワードが空欄でないこと' do
        customer.password = ''
        is_expected.to eq false
      end
      it 'パスワード(確認用)が空欄でないこと' do
        customer.password_confirmation = ''
        is_expected.to eq false
      end
      it '一意性があること(email)' do
        customer.email = other_customer.email
        is_expected.to eq false
      end
      it '一意性があること(電話番号)' do
        customer.telephone_number = other_customer.telephone_number
        is_expected.to eq false
      end
      it 'パスワードが暗号化されていること' do
        expect(customer.encrypted_password).to_not eq 'password'
      end
    end
  end
end