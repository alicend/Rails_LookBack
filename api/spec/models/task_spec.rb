require "rails_helper"

RSpec.describe Task, type: :model do
  # バリデーションのテスト
  describe "validations" do
    it "全ての項目が有効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: 1, estimate: 5, creator:, responsible:,
                      category:)
      expect(task).to be_valid
    end

    it "タスク名がない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: nil, description: "Example Description", status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "タスク名が0文字は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "", description: "Example Description", status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "タスク名が31文字以上の場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task_name = "a" * 31
      task = Task.new(task: task_name, description: "Example Description", status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "説明がない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: nil, status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "説明が0文字は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "", status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "説明が256文字以上の場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      description = "a" * 256
      task = Task.new(task: "Example Task", description:, status: 1, estimate: 5, creator:, responsible:, category:)
      expect(task).not_to be_valid
    end

    it "ステータスがない場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: nil, estimate: 5, creator:, responsible:,
                      category:)
      expect(task).not_to be_valid
    end

    it "ステータスが範囲外の場合は無効" do
      user_group = UserGroup.create!(name: "Example Group")
      creator = User.create!(name: "Creator User", email: "creator@example.com", password: "password", user_group:)
      responsible = User.create!(name: "Responsible User", email: "responsible@example.com", password: "password", user_group:)
      category = Category.create!(category: "Example Category", user_group:)
      task = Task.new(task: "Example Task", description: "Example Description", status: 5, estimate: 5, creator:, responsible:,
                      category:)
      expect(task).not_to be_valid
    end

    it "見積もりが範囲外の場合は無効" do
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
  describe "アソシエーション" do
    it { should belong_to(:creator).class_name("User").inverse_of(:created_tasks) }
    it { should belong_to(:responsible).class_name("User").inverse_of(:responsible_tasks) }
    it { should belong_to(:category) }
  end
end
