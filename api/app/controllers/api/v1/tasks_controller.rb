class Api::V1::TasksController < ApplicationController
  def task_board_index
    render json: { tasks: {} }, status: :ok
  end
end
