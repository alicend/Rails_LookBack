class Api::V1::CategoriesController < ApplicationController
  def index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group_id = UserGroup.joins(:users).where(users: { id: login_user_id }).select('user_groups.id').first
    Rails.logger.info("ログインユーザグループID : #{login_user_group_id}")

    categories = Category.where(user_group_id: login_user_group_id)
                  .order(:category)
                  .select('id AS ID', 'category AS Category')
    Rails.logger.info("カテゴリーの取得に成功")

    render json: { categories: categories }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    create_category_input = CreateCategoryInput.new(category: params[:category])

    unless create_category_input.valid?
      render json: { errors: create_category_input.errors.full_messages }, status: :bad_request
      return
    end

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select('user_groups.id').first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

    # 新しいカテゴリーを作成
    category = Category.new(category: create_category_input.category, user_group_id: login_user_group.id)
    unless category.save
      logger.error category.errors.full_messages
      return render json: { error: category.errors.full_messages }, status: :internal_server_error
    end

    categories = Category.where(user_group_id: login_user_group.id)
                  .order(:category)
                  .select('id AS ID', 'category AS Category')
    Rails.logger.info("カテゴリーの取得に成功")

    render json: { categories: categories }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの作成に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end
