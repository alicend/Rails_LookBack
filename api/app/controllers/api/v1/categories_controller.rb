class Api::V1::CategoriesController < ApplicationController
  def index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group_id = UserGroup.joins(:users).where(users: { id: login_user_id }).select('user_groups.id').first
    Rails.logger.info("ログインユーザグループID : #{login_user_group_id}")

    categories = Category.where(user_group_id: login_user_group_id).order(:category).select(:id, :category)
    Rails.logger.info("カテゴリーの取得に成功")

    render json: { categories: categories }, status: :ok
  rescue => e
    Rails.logger.error("カテゴリーの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end
