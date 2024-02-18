class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate

  def index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

    categories = Category.where(user_group_id: login_user_group.id).
                   order(:category).
                   select("id AS ID", "category AS Category")
    Rails.logger.info("カテゴリーの取得に成功")

    render json: { categories: }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    create_category_input = CategoryInput.new(category: params[:category])

    unless create_category_input.valid?
      Rails.logger.error(create_category_input.errors.full_messages)
      render json: { error: create_category_input.errors.full_messages }, status: :bad_request
      return
    end

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

    # カテゴリーを作成
    Category.create!(category: create_category_input.category, user_group_id: login_user_group.id)
    Rails.logger.info("カテゴリーの作成に成功")

    categories = Category.where(user_group_id: login_user_group.id).
                   order(:category).
                   select("id AS ID", "category AS Category")
    Rails.logger.info("カテゴリーの取得に成功")

    render json: { categories: }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの作成に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def update
    update_category_input = CategoryInput.new(category: params[:category])

    unless update_category_input.valid?
      Rails.logger.error(update_category_input.errors.full_messages)
      render json: { error: update_category_input.errors.full_messages }, status: :bad_request
      return
    end

    # カテゴリーを更新
    category = Category.find(params[:id])
    category.update!(category: update_category_input.category)
    Rails.logger.info("カテゴリーの更新に成功")

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

    categories = Category.where(user_group_id: login_user_group.id).
                   order(:category).
                   select("id AS ID", "category AS Category")
    Rails.logger.info("カテゴリーの取得に成功")

    tasks = Task.joins(:category).
              left_joins(:creator, :responsible).
              select(
                "tasks.id AS ID",
                "tasks.task AS Task",
                "tasks.description AS Description",
                "tasks.start_date AS StartDate",
                'DATE_FORMAT(tasks.start_date, "%Y-%m-%d") AS StartDate',
                "tasks.status AS Status",
                'CASE tasks.status WHEN 1 THEN "未着" WHEN 2 THEN "進行中" WHEN 3 THEN "完了" WHEN 4 THEN "Look Back" ELSE "Unknown status" END AS StatusName',
                "categories.id AS Category",
                "categories.category AS CategoryName",
                "tasks.estimate AS Estimate",
                "responsibles_tasks.id AS Responsible",
                "responsibles_tasks.name AS ResponsibleUserName",
                "users.id AS Creator",
                "users.name AS CreatorUserName",
                'DATE_FORMAT(tasks.created_at, "%Y-%m-%d %H:%i") AS CreatedAt',
                'DATE_FORMAT(tasks.updated_at, "%Y-%m-%d %H:%i") AS UpdatedAt',
              ).
              where.not(status: 4).
              where("categories.user_group_id = ?", login_user_group.id).
              order(created_at: :asc)
    Rails.logger.info("タスクボード用のタスクの取得に成功")

    render json: { categories:, tasks: }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy
    category = Category.find(params[:id])
    # カテゴリーと関連タスクを削除
    category.destroy!
    Rails.logger.info("カテゴリーの削除に成功")

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

    categories = Category.where(user_group_id: login_user_group.id).
                   order(:category).
                   select("id AS ID", "category AS Category")
    Rails.logger.info("カテゴリーの取得に成功")

    tasks = Task.joins(:category).
              left_joins(:creator, :responsible).
              select(
                "tasks.id AS ID",
                "tasks.task AS Task",
                "tasks.description AS Description",
                "tasks.start_date AS StartDate",
                'DATE_FORMAT(tasks.start_date, "%Y-%m-%d") AS StartDate',
                "tasks.status AS Status",
                'CASE tasks.status WHEN 1 THEN "未着" WHEN 2 THEN "進行中" WHEN 3 THEN "完了" WHEN 4 THEN "Look Back" ELSE "Unknown status" END AS StatusName',
                "categories.id AS Category",
                "categories.category AS CategoryName",
                "tasks.estimate AS Estimate",
                "responsibles_tasks.id AS Responsible",
                "responsibles_tasks.name AS ResponsibleUserName",
                "users.id AS Creator",
                "users.name AS CreatorUserName",
                'DATE_FORMAT(tasks.created_at, "%Y-%m-%d %H:%i") AS CreatedAt',
                'DATE_FORMAT(tasks.updated_at, "%Y-%m-%d %H:%i") AS UpdatedAt',
              ).
              where.not(status: 4).
              where("categories.user_group_id = ?", login_user_group.id).
              order(created_at: :asc)
    Rails.logger.info("タスクボード用のタスクの取得に成功")

    render json: { categories:, tasks: }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの削除に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end
