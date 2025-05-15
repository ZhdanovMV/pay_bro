require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "validates presence of email" do
      user = User.new(email: nil, password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "validates presence of password" do
      user = User.new(email: "user@example.com", password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "validates uniqueness of email" do
      _user1 = User.create(email: "user@example.com", password: "password123")
      user2 = User.new(email: "user@example.com", password: "password456")
      expect(user2).not_to be_valid
      expect(user2.errors[:email]).to include("has already been taken")
    end
  end
end
