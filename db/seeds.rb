# --- Admin 修正 (パスワード確認追加) ---
admin = Admin.find_or_initialize_by(email: 'aaa111@www.com')
if admin.new_record?
  admin.password = "testtest"
  admin.password_confirmation = "testtest" # 追加
  admin.save!
end

# --- アレルギーデータ (重複回避) ---
allergens.each do |allergen|
  Allergy.find_or_create_by!(allergen: allergen)
end

# --- 都道府県とエリア (find_or_create_by で重複回避) ---
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

# --- レストラン作成部分 (重要：password_confirmation を追加) ---
# ※ 全ての Restaurant.create! 内に password_confirmation: password を追記してください

# 例: 最初の loop 内
8.times do |n|
  password = "tuyukusa"
  Restaurant.create!(
    email: Faker::Internet.email,
    telephone_number: Faker::Number.number(digits: 11),
    is_valid: true,
    name: Faker::Restaurant.name,
    regular_holiday: "月曜日",
    business_hours: "10:00~21:00",
    address: Faker::Address.city + "115-6",
    area_id: 1 + n,
    state_id: 1,
    password: password,
    password_confirmation: password # ← これを全ての Restaurant.create! に追加！
  )
end
