require 'open-uri'

namespace :images do
  desc "画像が未添付のレストランとメニューにプレースホルダー画像を添付する"
  task attach_missing: :environment do
    restaurant_urls = (1..10).map { |n| "https://picsum.photos/seed/enme-rest#{n}/800/600" }
    menu_urls       = (1..10).map { |n| "https://picsum.photos/seed/enme-menu#{n}/400/300" }

    def dl(url, label)
      f = Tempfile.new([label, '.jpg'])
      f.binmode
      f.write(URI.open(url, read_timeout: 30).read)
      f.rewind
      f
    rescue => e
      puts "  DL失敗 #{label}: #{e.message}"
      nil
    end

    puts "画像ダウンロード中..."
    rest_imgs = restaurant_urls.map.with_index { |u, i| dl(u, "rest#{i}") }.compact
    menu_imgs = menu_urls.map.with_index       { |u, i| dl(u, "menu#{i}") }.compact
    puts "ダウンロード完了: 店舗#{rest_imgs.size}件, メニュー#{menu_imgs.size}件"

    puts "レストラン画像を添付中..."
    Restaurant.all.each_with_index do |r, i|
      next if r.image.attached?
      f = rest_imgs[i % rest_imgs.size]
      next unless f
      f.rewind
      r.image.attach(io: f, filename: "image.jpg", content_type: "image/jpeg")
      print "."
    end
    puts " 完了"

    puts "メニュー画像を添付中..."
    Menu.all.each_with_index do |m, i|
      next if m.image.attached?
      f = menu_imgs[i % menu_imgs.size]
      next unless f
      f.rewind
      m.image.attach(io: f, filename: "image.jpg", content_type: "image/jpeg")
      print "."
    end
    puts " 完了"

    (rest_imgs + menu_imgs).each { |f| f.close! rescue nil }
    puts "全て完了！"
  end
end
