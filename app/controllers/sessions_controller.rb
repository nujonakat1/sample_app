class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    # if user && user.authenticate(params[:session][:password])
    if @user&.authenticate(params[:session][:password])    #ぼっち演算子で記述
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      reset_session      # ログインの直前に必ずこれを書くこと
      # remember user      # ログインしてユーザーを保持する
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      log_in @user
      redirect_to @user
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    # log_out
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
