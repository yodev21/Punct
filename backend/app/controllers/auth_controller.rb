class AuthController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      status = :created
      message = 'ログインしました。'
    else
      status = :unauthorized
      message = 'メールアドレスまたはパスワードが正しくありません。'
    end
    render json: { message: message }, status: status
  end

  def destroy
    session.delete(:user_id)
  end
end
