class WeeklyTasksController < ApplicationController
  def index
    tasks = @current_user.weekly_tasks
    render json: { tasks: tasks }
  end

  def create
    task = @current_user.weekly_tasks.build(task_params)
    if task.save
      payload = { task: task }
      status = :created
    else
      payload = { message: task.errors.full_messages.join("\n") }
      status = :ok
    end
    render json: payload, status: status
  end

  def update
    task = WeeklyTask.find(params[:id])
    if task.update(task_params)
      head :no_content
    else
      render json: { error: task.errors.full_messages.join("\n") }
    end
  end

  def destroy
    task = WeeklyTask.find(params[:id])
    @current_user
      .weekly_tasks
      .where('long_tasks.start_date = ? AND long_tasks.order > ?', task.start_date, task.order)
      .update_all('long_tasks.order = long_tasks.order - 1')
    task.destroy
    render json: { tasks: @current_user.weekly_tasks }
  end

  def order
    # params = { oldIndex, newIndex, startDate }
    old_index = params[:oldIndex]
    new_index = params[:newIndex]
    start_date = params[:startDate]

    @current_user
      .weekly_tasks
      .where('long_tasks.start_date = ? AND long_tasks.order > ?', start_date, old_index)
      .update_all('long_tasks.order = long_tasks.order - 1')

    @current_user
      .weekly_tasks
      .where('long_tasks.start_date = ? AND long_tasks.order >= ?', start_date, new_index)
      .update_all('long_tasks.order = long_tasks.order + 1')

    @current_user
      .weekly_tasks
      .find_by(start_date: start_date, order: old_index)
      .update!(order: new_index)

    render json: { tasks: @current_user.weekly_tasks }
  end

  private

  def task_params
    params.require(:task).permit(:content, :is_checked, :start_date, :order)
  end
end