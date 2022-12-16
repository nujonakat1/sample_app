require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest

  def setup
    # 他のメール配信関連テストが壊れないようにする
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup

  # 無効な送信に対するテスト
  test "invalid signup information" do
    # get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'

		#id = "error_explanation"を持つdivがある
		assert_select 'div#error_explanation'

		#class = "alert-dange"を持つdivがある
		assert_select 'div.alert-danger'
  end
  # 目的はデータベースの中身が正しいかどうか検証すること
  # test "valid signup information" do
  test "valid signup information with account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end


class AccountActivationTest < UsersSignup

  def setup
    super
    post users_path, params: { user: { name:  "Example User",
                                       email: "user@example.com",
                                       password:              "password",
                                       password_confirmation: "password" } }
    @user = assigns(:user)
  end

  test "should not be activated" do
    assert_not @user.activated?
  end

  # 有効化されていないユーザーをログイン可能にしてはならない
  test "should not be able to log in before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  # 無効なトークンでユーザーを有効化できてはならない
  test "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  # 無効なメールアドレスでユーザーを有効化できてはならない
  test "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  # 有効なトークンとメールアドレスを使えばユーザーを有効化
  test "should log in successfully with valid activation token and email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?     # flashに対するテスト
    assert is_logged_in?        # ユーザー登録後すぐのログインのテスト
  end
end
