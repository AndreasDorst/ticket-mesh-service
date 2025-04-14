require 'faker'

puts "Seeding users..."

10.times do
  User.create!(
    full_name: Faker::Name.name,
    age: rand(18..65),
    document_type: %w[passport id_card driver_license].sample,
    document_number: Faker::IdNumber.valid,
    password: 'password' # важно: bcrypt требует `has_secure_password`, так что пароль должен быть осмысленным
  )
end

puts "✅ Done seeding users!"
