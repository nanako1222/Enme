# t.string "last_name", null: false
# t.string "first_name", null: false
# t.string "last_name_kana", null: false
# t.string "first_name_kana", null: false
# t.string "telephone_number", null: false
# t.integer "area_id", null: false
# t.integer "state_id", null: false
# t.boolean "is_valid", default: true, null: false

FactoryBot.define do
  factory :customer do
    last_name { Faker::Lorem.characters(number: 10) }
    first_name { Faker::Lorem.characters(number: 10) }
    last_name_kana { Faker::Lorem.characters(number: 10) }
    first_name_kana { Faker::Lorem.characters(number: 10) }
    telephone_number { Faker::Number.number(digits: 11) }
    area_id { 1 }
    state_id { 1 }
    is_valid { false }

    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end
end