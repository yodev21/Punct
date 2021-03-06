class AuthController < ApplicationController
  skip_before_action :check_xhr_header, only: [:name, :success, :failure]
  skip_before_action :require_login, except: [:destroy]

  def name
    name = current_user&.name
    render json: { name: name }
  end

  def create
    user = User.find_by(email: params[:email]&.downcase, provider: nil)
    if user&.authenticate(params[:password])
      log_in user
      params[:remember] ? remember(user) : forget(user)
      payload = { message: 'ログインしました。', name: user.name }
    else
      payload = { errors: ['メールアドレスまたはパスワードが正しくありません。'] }
    end
    render json: payload
  end

  def destroy
    log_out
    render json: { message: 'ログアウトしました。' }
  end

  def success
    auth = request.env['omniauth.auth']
    user = User.find_or_create_from_auth(auth)
    log_in user
    redirect_to ENV.fetch('FRONTEND_URL') + '/oauth'
  end

  def failure
    redirect_to ENV.fetch('FRONTEND_URL') + '/oauth'
  end

  def test
    user = User.create_test
    log_in user
    render json: { message: 'テストログインしました。データは7日後に削除されます。', name: user.name }
  end
end
