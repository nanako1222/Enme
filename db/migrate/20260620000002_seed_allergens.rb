class SeedAllergens < ActiveRecord::Migration[6.1]
  def up
    return if Allergy.exists?

    allergens = %w(
      卵 えび かに そば 落花生 小麦 乳 あわび イカ いくら
      オレンジ キウイ 牛肉 くるみ サケ りんご サバ 大豆
      鶏肉 バナナ 豚肉 まつたけ もも やまいも ゼラチン
      ごま カシューナッツ アーモンド
    )

    allergens.each do |allergen|
      Allergy.find_or_create_by!(allergen: allergen)
    end
  end

  def down
  end
end
