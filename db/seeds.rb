RESTAURANT_NAMES = %w[
  花まる食堂 麺処たかし 炭火焼鳥とり吉 居酒屋まつり 洋食ビストロ風
  寿司処さかな 天ぷら揚げ太 うどん麦の穂 焼肉牛太郎 カフェ彩り
  ラーメン大将 中華料理龍門 お好み焼き鶴橋 定食屋さくら 串カツ道場
  イタリアンベルフォーレ カレー香辛 蕎麦更科 海鮮丼まぐろ屋 焼きそば鉄板亭
  ちゃんこ鍋横綱 豚骨一家 鶏白湯麺とり屋 野菜ビュッフェ緑 もつ鍋博多風
  パスタの森 洋食グリル山 魚介ラーメン海風 創作和食雅 韓国料理ソウル
].freeze

MENU_NAMES = %w[
  醤油ラーメン 塩ラーメン みそラーメン 担々麺 つけ麺 ざるそば
  天ぷらうどん きつねうどん 親子丼 カツ丼 海鮮丼 まぐろ丼 天丼 牛丼
  唐揚げ定食 焼き魚定食 ハンバーグ定食 豚カツ定食 刺身定食 野菜炒め定食
  餃子 炒飯 麻婆豆腐 エビチリ 酢豚 八宝菜 回鍋肉
  天ぷら盛り合わせ 刺身盛り合わせ 寿司盛り合わせ 焼き鳥盛り合わせ 串カツ盛り合わせ
  お好み焼き たこ焼き 焼きそば もんじゃ焼き
  カレーライス ハヤシライス オムライス ナポリタン
  マルゲリータピザ ペペロンチーノ カルボナーラ ボロネーゼ
  ハンバーグ ビーフシチュー チキンソテー サーモンムニエル
  唐揚げ コロッケ メンチカツ アジフライ エビフライ
  冷やし中華 焼きうどん チャーシュー麺 ワンタン麺 五目そば
].freeze

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
SEEDS_IMAGE_DIR = Rails.root.join("db/seeds/images")

def load_image_data(dir)
  Dir[dir.join("*")].sort.map { |path| File.binread(path) }
end

def attach_image(record, data_list, index)
  return if data_list.empty?
  data = data_list[index % data_list.length]
  ext  = "jpg"
  record.image.attach(io: StringIO.new(data), filename: "image.#{ext}", content_type: "image/jpeg")
rescue => e
  puts "  画像添付失敗: #{e.message}"
end

restaurant_images = load_image_data(SEEDS_IMAGE_DIR.join("restaurants"))
menu_images       = load_image_data(SEEDS_IMAGE_DIR.join("menus"))
puts "画像読み込み完了: 店舗#{restaurant_images.length}件, メニュー#{menu_images.length}件"

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
        name: RESTAURANT_NAMES.sample,
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
      name: MENU_NAMES.sample,
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

puts "シード完了！"
