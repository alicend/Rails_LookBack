require "rails_helper"

RSpec.describe Task, type: :model do
  # バリデーションのテスト
  describe "validations" do
    it "is valid with valid attributes" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: 1, estimate: 5, creator:, responsible:,
                      category:)
      expect(task).to be_valid
    end

    it "is invalid without a task name" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: nil, description: "Example Description", status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "is invalid without a description" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: nil, status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "is invalid without a status" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: nil, estimate: 5, creator:, responsible:,
                      category:)
      expect(task).not_to be_valid
    end

    it "is invalid with a status out of range" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: 5, estimate: 5, creator:, responsible:,
                      category:)
      expect(task).not_to be_valid
    end

    it "is valid with an estimate within range" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: 1, estimate: 100, creator:, responsible:,
                      category:)
      expect(task).to be_valid
    end

    it "is invalid with an estimate out of range" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: 1, estimate: 1001, creator:, responsible:,
                      category:)
      expect(task).not_to be_valid
    end
  end

  # アソシエーションのテスト
  describe "associations" do
    it { should belong_to(:creator).class_name("User").inverse_of(:created_tasks) }
    it { should belong_to(:responsible).class_name("User").inverse_of(:responsible_tasks) }
    it { should belong_to(:category) }
  end
end
