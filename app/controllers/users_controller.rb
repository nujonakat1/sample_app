class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(params[:user])    # 実装は終わっていないことに注意!
    @user = User.new(user_params)
    if @user.save
      # 保存の成功をここで扱う。
      reset_session     # ユーザー登録中にログインする
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      # redirect_to user_url(@user)
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private		# privateキーワード

  def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end


end
