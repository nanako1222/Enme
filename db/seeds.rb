# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = Admin.find_or_initialize_by(
   email: 'aaa@www'
)
if admin.new_record?
    admin.password = "testtest"
    admin.save!
end

Allergy.create!([{allergen: "なし"}, {allergen: "卵"}, {allergen:"えび"}, {allergen: "かに"}, {allergen:"そば"}, {allergen: "落花生"}, {allergen:"小麦"},
{allergen: "乳"}, {allergen:"あわび"}, {allergen: "イカ"}, {allergen:"いくら"}, {allergen: "オレンジ"}, {allergen:"キウイ"}, {allergen:"牛肉"},
{allergen: "くるみ"}, {allergen:"サケ"}, {allergen: "りんご"}, {allergen:"サバ"}, {allergen: "大豆"}, {allergen:"鶏肉"}, {allergen:"バナナ"},
{allergen: "豚肉"}, {allergen:"まつたけ"}, {allergen: "もも"}, {allergen:"やまいも"}, {allergen: "ゼラチン"}, {allergen:"ごま"}, {allergen:"カシューナッツ"},
{allergen:"アーモンド"}
])


#Admin.create!(password: "testtest")
# admin.update!(password: "testtest")

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