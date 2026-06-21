require 'open-uri'

namespace :images do
  desc "画像が未添付のレストランとメニューにプレースホルダー画像を添付する"
  task attach_missing: :environment do
    restaurant_urls = (1..10).map { |n| "https://loremflickr.com/800/600/restaurant?lock=#{n}" }
    menu_urls       = (1..10).map { |n| "https://loremflickr.com/400/300/food?lock=#{n}" }

    puts "画像ダウンロード中..."
    rest_data = restaurant_urls.each_with_index.map do |url, i|
      URI.open(url, read_timeout: 30).read
    rescue => e
      puts "  DL失敗 rest#{i}: #{e.message}"
      nil
    end.compact

    menu_data = menu_urls.each_with_index.map do |url, i|
      URI.open(url, read_timeout: 30).read
    rescue => e
      puts "  DL失敗 menu#{i}: #{e.message}"
      nil
    end.compact

    puts "ダウンロード完了: 店舗#{rest_data.size}件, メニュー#{menu_data.size}件"

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
