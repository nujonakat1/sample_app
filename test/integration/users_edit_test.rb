require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # 編集の失敗に対するテスト
  test "unsuccessful edit" do
    log_in_as(@user)    # 先にログインしておく
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'  # users/editが描写される
  end

  # 編集成功時に対するテスト
  # test "successful edit" do
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    # session[:forwarding_url] と edit_user_url(@user) が等しい時に true
		assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)    # 編集ページにアクセス後に@userとしてログイン
    # session[:forwarding_url]が nil の時 true
		assert_nil session[:forwarding_url]
    # assert_template 'users/edit'
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
                                              # パスワードはあえて空に
    assert_not flash.empty?
    assert_redirected_to @user    # プロフィールページにリダイレクトされるかどうかをチェック
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
