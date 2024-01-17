class Api::V1::TasksController < ApplicationController
  def task_board_index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group_id = UserGroup.joins(:users).where(users: { id: login_user_group_id }).select('user_groups.id').first
    Rails.logger.info("ログインユーザグループID : #{login_user_group_id}")

    tasks = Task.joins(:category)
            .left_joins(:creator, :responsible)
            .select(
                'tasks.id AS ID',
                'tasks.task AS Task',
                'tasks.description AS Description',
                'tasks.start_date AS StartDate',
                'tasks.status AS Status',
                'CASE tasks.status WHEN 1 THEN "未着" WHEN 2 THEN "進行中" WHEN 3 THEN "完了" WHEN 4 THEN "Look Back" ELSE "Unknown status" END AS StatusName',
                'categories.id AS Category',
                'categories.category AS CategoryName',
                'tasks.estimate AS Estimate',
                'responsibles_tasks.id AS Responsible',
                'responsibles_tasks.name AS ResponsibleUserName',
                'users.id AS Creator',
                'users.name AS CreatorUserName',
                'tasks.created_at AS CreatedAt',
                'tasks.updated_at AS UpdatedAt'
            )
            .where.not(status: 4)
            .order(created_at: :asc)
    Rails.logger.info("タスクボード用のタスクの取得に成功")

    render json: { tasks: tasks }, status: :ok
  rescue => e
    Rails.logger.error("タスクボード用のタスクの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end
