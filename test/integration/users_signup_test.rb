require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  # 無効な送信に対するテスト
  test "invalid signup information" do
    get signup_path
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
  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    # assert_template 'users/show'
    # assert_not flash.empty?     # flashに対するテスト
    # assert is_logged_in?        # ユーザー登録後すぐのログインのテスト
  end

end
