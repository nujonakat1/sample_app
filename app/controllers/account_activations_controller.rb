class AccountActivationsController < ApplicationController
  # paramsハッシュで渡されたメールアドレスに対応するユーザーを認証する
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # 有効だった場合、ユーザーを認証してから activated_at タイムスタンプを更新
      # user.update_attribute(:activated,    true)
      # user.update_attribute(:activated_at, Time.zone.now)
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      # 有効化トークンが無効だった場合の処理
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
