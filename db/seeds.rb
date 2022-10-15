# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Admin.create!(
   email: 'aaa@www',
   password: 'testtest',
)

Area.create([{area: "大阪市"}, {area: "北河内"}, {area: "中河内"}, {area: "豊能"}, {area: "三島"},
            {area: "泉北"}, {area: "泉南"}, {area: "南河内"}])

Area.create([{area: "但馬"}, {area: "神戸市"}, {area: "北播磨"}, {area: "中播磨"}, {area: "東播磨"},
            {area: "西播磨"}, {area: "丹波"}, {area: "阪神北"}, {area: "阪神南"}, {area: "淡路"}])

Area.create([{area: "丹後"}, {area: "中丹"}, {area: "南丹"}, {area: "京都市"}, {area: "山城"}])

Area.create([{area: "湖北"}, {area: "湖東"}, {area: "湖西"}, {area: "東近江"}, {area: "大津市"}, {area: "湖南"}, {area: "甲賀"}])

Area.create([{area: "和歌山市"}, {area: "高野山"}, {area: "紀中"}, {area: "熊野"}, {area: "白浜・串本"}])

Area.create([{area: "奈良市"}, {area: "生駒・信貴・斑鳩・葛城"}, {area: "山の辺・飛鳥・橿原・宇陀"}, {area: "吉野路"}])