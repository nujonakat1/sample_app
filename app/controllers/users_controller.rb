class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # @users = User.all
    @users = User.paginate(page: params[:page])   # paginate メソッドを使えるようにする
    # 有効なユーザーだけを表示するコード
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(params[:user])    # 実装は終わっていないことに注意!
    @user = User.new(user_params)
    if @user.save
      # 保存の成功をここで扱う。
      # reset_session     # ユーザー登録中にログインする
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # # redirect_to user_url(@user)
      # redirect_to @user
      # UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update    # 初期実装
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 更新に成功した場合を扱う
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  private		# privateキーワード

  def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # beforeフィルター

  # ログイン済みユーザーかどうか確認
  # def logged_in_user
  #   unless logged_in?
  #     store_location
  #     flash[:danger] = "Please log in."
  #     redirect_to login_url, status: :see_other
  #   end
  # end

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    # redirect_to(root_url, status: :see_other) unless @user == current_user
    # 直接比較を論理値メソッドで置き換えた
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
