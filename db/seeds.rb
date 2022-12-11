# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = Admin.find_or_initialize_by(
  email: 'aaa111@www.com'
)
if admin.new_record?
    admin.password = "testtest"
    admin.save!
end

allergens = %w(
  卵
  えび
  かに
  そば
  落花生
  小麦
  乳
  あわび
  イカ
  いくら
  オレンジ
  キウイ
  牛肉
  くるみ
  サケ
  りんご
  サバ
  大豆
  鶏肉
  バナナ
  豚肉
  まつたけ
  もも
  やまいも
  ゼラチン
  ごま
  カシューナッツ
  アーモンド
)

allergens.each do |allergen|
  Allergy.create!(allergen: allergen)
end

osaka = State.create!(state: "大阪府")
osaka.areas.create!([{area: "大阪市"}, {area: "北河内"}, {area: "中河内"}, {area: "豊能"}, {area: "三島"},
            {area: "泉北"}, {area: "泉南"}, {area: "南河内"}])

hyogo = State.create!(state: "兵庫県")
hyogo.areas.create!([{area: "但馬"}, {area: "神戸市"}, {area: "北播磨"}, {area: "中播磨"}, {area: "東播磨"},
            {area: "西播磨"}, {area: "丹波"}, {area: "阪神北"}, {area: "阪神南"}, {area: "淡路"}])

kyoto = State.create!(state: "京都府")
kyoto.areas.create!([{area: "丹後"}, {area: "中丹"}, {area: "南丹"}, {area: "京都市"}, {area: "山城"}])

shiga = State.create!(state: "滋賀県")
shiga.areas.create!([{area: "湖北"}, {area: "湖東"}, {area: "湖西"}, {area: "東近江"}, {area: "大津市"}, {area: "湖南"}, {area: "甲賀"}])

wakayama = State.create!(state: "和歌山県")
wakayama.areas.create!([{area: "和歌山市"}, {area: "高野山"}, {area: "紀中"}, {area: "熊野"}, {area: "白浜・串本"}])

nara = State.create!(state: "奈良県")
nara.areas.create!([{area: "奈良市"}, {area: "生駒・信貴・斑鳩・葛城"}, {area: "山の辺・飛鳥・橿原・宇陀"}, {area: "吉野路"}])

# #エリア毎に分けて作っているので一つにまとめれたらスッキリする

5.times do |i|
  8.times do |n|
    email = Faker::Internet.email
    encrypted_password = "tuyukusa"
    telephone_number = Faker::Number.number(digits: 11)
    name = Faker::Restaurant.name
    regular_holiday = "月曜日"
    address = Faker::Address.city + "115-6"
    area_id = 1 + n
    state_id = 1
    password = "tuyukusa"

    Restaurant.create!(
      email: email,
      encrypted_password: encrypted_password,
      telephone_number: telephone_number,
      is_valid: true,
      name: name,
      regular_holiday: regular_holiday,
      business_hours: "10:00~21:00",
      address: address,
      area_id: area_id,
      state_id: state_id,
      password: password,
    )
  end

  10.times do |n|
    email = Faker::Internet.email
    encrypted_password = "tuyukusa"
    telephone_number = Faker::Number.number(digits: 11)
    name = Faker::Restaurant.name
    regular_holiday = "月曜日"
    address = Faker::Address.city + "115-6"
    area_id = 9 + n
    state_id = 2
    password = "tuyukusa"

    Restaurant.create!(
      email: email,
      encrypted_password: encrypted_password,
      telephone_number: telephone_number,
      is_valid: true,
      name: name,
      regular_holiday: regular_holiday,
      business_hours: "10:00~21:00",
      address: address,
      area_id: area_id,
      state_id: state_id,
      password: password,
    )
  end

  5.times do |n|
    email = Faker::Internet.email
    encrypted_password = "tuyukusa"
    telephone_number = Faker::Number.number(digits: 11)
    name = Faker::Restaurant.name
    regular_holiday = "月曜日"
    address = Faker::Address.city + "115-6"
    area_id = 19 + n
    state_id = 3
    password = "tuyukusa"

    Restaurant.create!(
      email: email,
      encrypted_password: encrypted_password,
      telephone_number: telephone_number,
      is_valid: true,
      name: name,
      regular_holiday: regular_holiday,
      business_hours: "10:00~21:00",
      address: address,
      area_id: area_id,
      state_id: state_id,
      password: password,
    )
  end

  7.times do |n|
    email = Faker::Internet.email
    encrypted_password = "tuyukusa"
    telephone_number = Faker::Number.number(digits: 11)
    name = Faker::Restaurant.name
    regular_holiday = "月曜日"
    address = Faker::Address.city + "115-6"
    area_id = 24 + n
    state_id = 4
    password = "tuyukusa"

    Restaurant.create!(
      email: email,
      encrypted_password: encrypted_password,
      telephone_number: telephone_number,
      is_valid: true,
      name: name,
      regular_holiday: regular_holiday,
      business_hours: "10:00~21:00",
      address: address,
      area_id: area_id,
      state_id: state_id,
      password: password,
    )
  end

  5.times do |n|
    email = Faker::Internet.email
    encrypted_password = "tuyukusa"
    telephone_number = Faker::Number.number(digits: 11)
    name = Faker::Restaurant.name
    regular_holiday = "月曜日"
    address = Faker::Address.city + "115-6"
    area_id = 31 + n
    state_id = 5
    password = "tuyukusa"

    Restaurant.create!(
      email: email,
      encrypted_password: encrypted_password,
      telephone_number: telephone_number,
      is_valid: true,
      name: name,
      regular_holiday: regular_holiday,
      business_hours: "10:00~21:00",
      address: address,
      area_id: area_id,
      state_id: state_id,
      password: password,
    )
  end

  4.times do |n|
    email = Faker::Internet.email
    encrypted_password = "tuyukusa"
    telephone_number = Faker::Number.number(digits: 11)
    name = Faker::Restaurant.name
    regular_holiday = "月曜日"
    address = Faker::Address.city + "115-6"
    area_id = 36 + n
    state_id = 6
    password = "tuyukusa"

    Restaurant.create!(
      email: email,
      encrypted_password: encrypted_password,
      telephone_number: telephone_number,
      is_valid: true,
      name: name,
      regular_holiday: regular_holiday,
      business_hours: "10:00~21:00",
      address: address,
      area_id: area_id,
      state_id: state_id,
      password: password,
    )
  end
end

195.times do |n|
  name = Faker::Food.dish
  introduction = "こだわりの素材を使用した体に優しい一品です。"
  price = Faker::Number.number(digits: 3)
  restaurant_id = 1 + n

  Menu.create!(
    name: name,
    introduction: introduction,
    price: price,
    restaurant_id: restaurant_id,
  )
end

(1..195).each do |menu_id|
  allergy_id = menu_id % 28
  allergy_id = 28 if allergy_id == 0
  MenuHavingAllergy.create!(
    menu_id: menu_id,
    allergy_id: allergy_id,
  )
end

# state_areas = {"大阪府" => %w{大阪市 北河内 中河内 豊能 三島},
#         "兵庫県" => %w{但馬 神戸市 北播磨 中播磨 東播磨 西播磨 丹波 阪神北 阪神南 淡路},
#         "京都府" => %w{丹後 中丹 南丹 京都市 山城},
#         "滋賀県" => %w{湖北 湖東 湖西 東近江 大津市 湖南 甲賀},
#         "和歌山県" => %w{和歌山市 高野山 紀中 熊野 白浜・串本},
#         "奈良県" => %w{奈良市 生駒・信貴・斑鳩・葛城 山の辺・飛鳥・橿原・宇陀 吉野路}}
         
# state_areas.each do |key, areas|
#   state = State.create!(state: key)
#   areas.each do |name|
#     area = state.areas.create!(area: name)

#     Restaurant.create!(
#       email: Faker::Internet.email,
#       encrypted_password: "tuyukusa",
#       telephone_number: Faker::Number.number(digits: 11),
#       is_valid: true,
#       name: Faker::Restaurant.name,
#       regular_holiday: "月曜日",
#       business_hours: "10:00~21:00",
#       address: Faker::Address.city + "115-6",
#       area_id: area.id,
#       state_id: state.id,
#       password: "tuyukusa",
#     )
#   end
# end

#menu_having_allerugyのアレルギーの数をeachでまわしている
#メニューの数でまわしてアレルギーの数が１〜２８を繰り返したらひとつにまとまる
#if文がうまく作動しなかった

# 28.times do |n|
#   menu_id = 1 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end

# 28.times do |n|
#   menu_id = 29 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end

# 28.times do |n|
#   menu_id = 57 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end

# 28.times do |n|
#   menu_id = 85 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end

# 28.times do |n|
#   menu_id = 113 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end

# 28.times do |n|
#   menu_id = 141 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end

# 25.times do |n|
#   menu_id = 169 + n
#   allergy_id = 1 + n

#   MenuHavingAllergy.create!(
#     menu_id: menu_id,
#     allergy_id: allergy_id,
#   )
# end