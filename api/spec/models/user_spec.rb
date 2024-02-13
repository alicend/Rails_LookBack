require "rails_helper"

RSpec.describe User, type: :model do
  describe "ヴァリデーション" do
    it "全ての項目が有効" do
      user_group = UserGroup.create!(name: "Example Group")
      user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password", user_group:)
      expect(user).to be_valid
    end

    it "名前がない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      user = User.new(name: nil, email: "john@example.com", password: "password", password_confirmation: "password", user_group:)
      expect(user).not_to be_valid
    end

    it "メールがない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      user = User.new(name: "John Doe", email: nil, password: "password", password_confirmation: "password", user_group:)
      expect(user).not_to be_valid
    end

    it "メールが重複している場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      User.create!(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password", user_group:)
      user = User.new(name: "Jane Doe", email: "john@example.com", password: "password", password_confirmation: "password", user_group:)
      expect(user).not_to be_valid
    end

    it "名前が31文字以上の場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      name = "a" * 31
      user = User.new(name:, email: "john@example.com", password: "password", password_confirmation: "password", user_group:)
      expect(user).not_to be_valid
    end

    it "メールが256文字以上の場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      email = "#{"a" * 244}@example.com"
      user = User.new(name: "John Doe", email:, password: "password", password_confirmation: "password", user_group:)
      expect(user).not_to be_valid
    end

    it "パスワードがない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      user = User.new(name: "John Doe", email: "john@example.com", password: nil, password_confirmation: "password", user_group:)
      expect(user).not_to be_valid
    end

    it "パスワードとパスワード確認が一致しない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "different", user_group:)
      expect(user).not_to be_valid
    end
  end

  # アソシエーションのテスト
  describe "アソシエーション" do
    it { should belong_to(:user_group) }
    it { should have_many(:created_tasks).with_foreign_key("creator_id").dependent(:destroy).class_name("Task") }
    it { should have_many(:responsible_tasks).with_foreign_key("responsible_id").dependent(:destroy).class_name("Task") }
  end
end
