puts "Seeding users..."

users_data = [
  { id: 1, full_name: "Alice Johnson", age: 30, document_type: "passport", document_number: "AA123456", password: "password" },
  { id: 2, full_name: "Bob Smith", age: 42, document_type: "id_card", document_number: "ID789123", password: "password" },
  { id: 3, full_name: "Charlie Brown", age: 28, document_type: "driver_license", document_number: "DL456789", password: "password" },
  { id: 4, full_name: "Dana White", age: 35, document_type: "passport", document_number: "AA999999", password: "password" },
  { id: 5, full_name: "Eve Adams", age: 26, document_type: "passport", document_number: "AB555666", password: "password" }
]

User.delete_all

users_data.each do |attrs|
  User.create!(attrs)
end

puts "✅ Created #{User.count} users!"