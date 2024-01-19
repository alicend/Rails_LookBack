class Api::V1::UserGroupsController < ApplicationController

  def update
    update_current_user_group_input = UpdateCurrentUserGroupInput.new(userGroup: params[:userGroup])

    user_group = UserGroup.find(params[:id])
    user_group.update!(
      name: update_current_user_group_input.userGroup,
    )
    Rails.logger.info("ユーザグループ名の更新に成功")

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    user = User.left_joins(:user_group)
              .select(
                'users.id AS ID',
                'users.email AS Email',
                'users.name AS Name',
                'users.user_group_id AS UserGroupID',
                'user_groups.name AS UserGroup',
                )
                .find_by(id: login_user_id)
    Rails.logger.info("ログインユーザのの取得に成功")

    render json: { user: user }, status: :ok
  rescue => e
    Rails.logger.error("ユーザグループ名の更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy

    # ユーザグループを削除
    user_group = UserGroup.find(params[:id])
    user_group.destroy!
    Rails.logger.info("ユーザグループの削除に成功")

    cookies.delete(:access_token, httponly: true, secure: true)
    cookies.delete(:guest_login, httponly: true, secure: true)

    render json: {}, status: :ok
  rescue => e
    Rails.logger.error("ユーザグループの削除に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

end
