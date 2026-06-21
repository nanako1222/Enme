require 'open-uri'

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

# 4. シード用画像の準備
# 5種類ずつダウンロードして使い回す（全件ダウンロードすると時間がかかりすぎるため）
RESTAURANT_IMAGE_URLS = (1..10).map { |n|
  "https://loremflickr.com/800/600/restaurant,building?lock=#{n}"
}.freeze

MENU_IMAGE_URLS = (1..10).map { |n|
  "https://loremflickr.com/400/300/food,dish?lock=#{n}"
}.freeze

def download_image(url, label)
  file = Tempfile.new([label, '.jpg'])
  file.binmode
  file.write(URI.open(url, read_timeout: 30).read)
  file.rewind
  file
rescue => e
  puts "  画像ダウンロード失敗 (#{label}): #{e.message}"
  nil
end

def attach_image(record, files, index)
  return if files.empty?
  file = files[index % files.length]
  return unless file
  file.rewind
  record.image.attach(io: file, filename: "image.jpg", content_type: "image/jpeg")
rescue => e
  puts "  画像添付失敗: #{e.message}"
end

puts "店舗画像をダウンロード中..."
restaurant_images = RESTAURANT_IMAGE_URLS.map.with_index { |url, i| download_image(url, "rest#{i}") }.compact
puts "メニュー画像をダウンロード中..."
menu_images = MENU_IMAGE_URLS.map.with_index { |url, i| download_image(url, "menu#{i}") }.compact
puts "ダウンロード完了: 店舗#{restaurant_images.length}件, メニュー#{menu_images.length}件"

# 5. レストラン (Restaurants)
restaurant_idx = 0
states_data.each_with_index do |(state_name, area_names), state_idx|
  state = State.find_by(state: state_name)

  5.times do
    area_names.each_with_index do |_, area_idx|
      password = "tuyukusa"
      restaurant = Restaurant.create!(
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
      attach_image(restaurant, restaurant_images, restaurant_idx)
      restaurant_idx += 1
    end
  end
end

# 6. メニュー (Menus)
menu_idx = 0
Restaurant.all.each do |restaurant|
  3.times do
    menu = Menu.create!(
      name: Faker::Food.dish,
      introduction: "こだわりの素材を使用した体に優しい一品です。",
      price: Faker::Number.number(digits: 3),
      restaurant_id: restaurant.id
    )

    MenuHavingAllergy.create!(
      menu_id: menu.id,
      allergy_id: Allergy.all.sample.id
    )

    attach_image(menu, menu_images, menu_idx)
    menu_idx += 1
  end
end

# 後処理
(restaurant_images + menu_images).each { |f| f.close! rescue nil }
puts "シード完了！"
