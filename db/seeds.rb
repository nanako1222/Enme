# 1. 管理者 (Admin)
admin = Admin.find_or_initialize_by(email: 'aaa111@www.com')
if admin.new_record?
  admin.password = "testtest"
  admin.password_confirmation = "testtest"
  admin.save!
end

# 2. アレルギー項目 (Allergens)
allergens = %w(
  卵 えび かに そば 落花生 小麦 乳 あわび イカ いくら
  オレンジ キウイ 牛肉 くるみ サケ りんご サバ 大豆
  鶏肉 バナナ 豚肉 まつたけ もも やまいも ゼラチン
  ごま カシューナッツ アーモンド
)

allergens.each do |allergen|
  Allergy.find_or_create_by!(allergen: allergen)
end

# 3. 都道府県とエリア (States and Areas)
states_data = {
  "大阪府" => ["大阪市", "北河内", "中河内", "豊能", "三島", "泉北", "泉南", "南河内"],
  "兵庫県" => ["但馬", "神戸市", "北播磨", "中播磨", "東播磨", "西播磨", "丹波", "阪神北", "阪神南", "淡路"],
  "京都府" => ["丹後", "中丹", "南丹", "京都市", "山城"],
  "滋賀県" => ["湖北", "湖東", "湖西", "東近江", "大津市", "湖南", "甲賀"],
  "和歌山県" => ["和歌山市", "高野山", "紀中", "熊野", "白浜・串本"],
  "奈良県" => ["奈良市", "生駒・信貴・斑鳩・葛城", "山の辺・飛鳥・橿原・宇陀", "吉野路"]
}

states_data.each do |state_name, area_names|
  state = State.find_or_create_by!(state: state_name)
  area_names.each do |a_name|
    state.areas.find_or_create_by!(area: a_name)
  end
end

# 4. レストラン (Restaurants)
# 各都府県ごとに最初のエリアIDを基準に作成
base_area_id = 1
states_data.each_with_index do |(state_name, area_names), state_idx|
  state = State.find_by(state: state_name)
  
  5.times do
    area_names.each_with_index do |_, area_idx|
      password = "tuyukusa"
      Restaurant.create!(
        email: Faker::Internet.unique.email,
        telephone_number: Faker::Number.number(digits: 11),
        is_valid: true,
        name: Faker::Restaurant.name,
        regular_holiday: "月曜日",
        business_hours: "10:00~21:00",
        address: Faker::Address.city + "115-6",
        state_id: state.id,
        area_id: state.areas[area_idx].id,
        password: password,
        password_confirmation: password
      )
    end
  end
end

# 5. メニュー (Menus)
Restaurant.all.each do |restaurant|
  3.times do
    menu = Menu.create!(
      name: Faker::Food.dish,
      introduction: "こだわりの素材を使用した体に優しい一品です。",
      price: Faker::Number.number(digits: 3),
      restaurant_id: restaurant.id
    )
    
    # メニューにランダムなアレルギーを紐付け
    MenuHavingAllergy.create!(
      menu_id: menu.id,
      allergy_id: Allergy.all.sample.id
    )
  end
end
