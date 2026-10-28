# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
test_users = [
  { email: "user@test.cz", minecraft_nick: "TestUser", role: "user" },
  { email: "owner@test.cz", minecraft_nick: "TestOwner", role: "server_owner" },
  { email: "approver@test.cz", minecraft_nick: "TestApprover", role: "approver" },
  { email: "admin@test.cz", minecraft_nick: "TestAdmin", role: "admin" },
  { email: "superadmin@test.cz", minecraft_nick: "TestSuperadmin", role: "superadmin" }
]

test_users.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.minecraft_nick = attrs[:minecraft_nick]
    user.role = attrs[:role]
    user.password = "password123"
    user.password_confirmation = "password123"
  end
end

puts "Vytvořeno #{User.count} uživatelů: #{User.pluck(:minecraft_nick, :role)}"
