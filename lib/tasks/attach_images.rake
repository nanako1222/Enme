namespace :images do
  desc "画像が未添付のレストランとメニューにseed画像を添付する"
  task attach_missing: :environment do
    image_dir = Rails.root.join("db/seeds/images")

    rest_data = Dir[image_dir.join("restaurants/*")].sort.map { |p| File.binread(p) }
    menu_data = Dir[image_dir.join("menus/*")].sort.map { |p| File.binread(p) }
    puts "画像読み込み: 店舗#{rest_data.size}件, メニュー#{menu_data.size}件"

    puts "レストラン画像を添付中..."
    Restaurant.all.each_with_index do |r, i|
      next if r.image.attached?
      data = rest_data[i % rest_data.size]
      next unless data
      r.image.attach(io: StringIO.new(data), filename: "image.jpg", content_type: "image/jpeg")
      print "."
    rescue => e
      puts "\n  失敗 restaurant##{r.id}: #{e.message}"
    end
    puts " 完了"

    puts "メニュー画像を添付中..."
    Menu.all.each_with_index do |m, i|
      next if m.image.attached?
      data = menu_data[i % menu_data.size]
      next unless data
      m.image.attach(io: StringIO.new(data), filename: "image.jpg", content_type: "image/jpeg")
      print "."
    rescue => e
      puts "\n  失敗 menu##{m.id}: #{e.message}"
    end
    puts " 完了"

    puts "全て完了！"
  end
end
