class Api::V1::TasksController < ApplicationController
  before_action :authenticate

  def task_board_index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

    tasks = Task.joins(:category).
              left_joins(:creator, :responsible).
              select(
                "tasks.id AS ID",
                "tasks.task AS Task",
                "tasks.description AS Description",
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
    Rails.logger.info("ルックバック用のタスクの取得に成功")

    render json: { tasks: }, status: :ok
  rescue => e
    Rails.logger.error("タスクボード用のタスクの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def look_back_index
    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

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
              where(status: 4).
              where("categories.user_group_id = ?", login_user_group.id).
              order(created_at: :asc)
    Rails.logger.info("ルックバック用のタスクの取得に成功")

    render json: { tasks: }, status: :ok
  rescue => e
    Rails.logger.error("ルックバック用のタスクの取得に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    create_task_input = TaskInput.new(task_params)

    unless create_task_input.valid?
      Rails.logger.error(create_task_input.errors.full_messages)
      render json: { error: create_task_input.errors.full_messages }, status: :bad_request
      return
    end

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    # タスクを作成
    Task.create!(
      task: create_task_input.task,
      description: create_task_input.description,
      creator_id: login_user_id,
      category_id: create_task_input.category,
      status: create_task_input.status,
      responsible_id: create_task_input.responsible,
      estimate: create_task_input.estimate,
      start_date: create_task_input.start_date,
    )
    Rails.logger.info("タスクの作成に成功")

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

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

    render json: { tasks: }, status: :ok
  rescue => e
    Rails.logger.error("タスクの作成に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def update
    update_task_input = TaskInput.new(task_params)

    unless update_task_input.valid?
      Rails.logger.error(update_task_input.errors.full_messages)
      render json: { error: update_task_input.errors.full_messages }, status: :bad_request
      return
    end

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    # タスクを更新
    task = Task.find(update_task_input.id)
    task.update!(
      task: update_task_input.task,
      description: update_task_input.description,
      creator_id: login_user_id,
      category_id: update_task_input.category,
      status: update_task_input.status,
      responsible_id: update_task_input.responsible,
      estimate: update_task_input.estimate,
      start_date: update_task_input.start_date,
    )
    Rails.logger.info("タスクの更新に成功")

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

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

    render json: { tasks: }, status: :ok
  rescue => e
    Rails.logger.error("タスクの更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_to_completed
    # タスクを更新
    task = Task.find(params[:id])
    task.update!(status: 3)
    Rails.logger.info("タスクのステータスを完了する更新に成功")

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

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
              where(status: 4).
              where("categories.user_group_id = ?", login_user_group.id).
              order(created_at: :asc)
    Rails.logger.info("ルックバック用のタスクの取得に成功")

    render json: { tasks: }, status: :ok
  rescue => e
    Rails.logger.error("ルックバック用のタスクの更新に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy
    # タスクを削除
    task = Task.find(params[:id])
    task.destroy!
    Rails.logger.info("タスクの削除に成功")

    login_user_id = extract_user_id
    unless login_user_id
      Rails.logger.error("CookieからユーザIDの抽出に失敗")
      return render json: { error: "Failed to extract user ID" }, status: :internal_server_error
    end

    login_user_group = UserGroup.joins(:users).where(users: { id: login_user_id }).select("user_groups.id").first
    Rails.logger.info("ログインユーザグループID : #{login_user_group.id}")

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

    render json: { tasks: }, status: :ok
  rescue => e
    Rails.logger.error("タスクの削除に失敗しました: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  private

    def task_params
      params.permit(:ID, :Task, :Description, :StartDate, :Estimate, :Responsible, :Status, :Category).
        transform_keys(&:underscore)
    end
end
