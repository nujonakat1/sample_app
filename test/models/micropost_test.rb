require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # このmicropostを作成するコードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  # 現実に即しているかどうかのテスト
  test "should be valid" do
    assert @micropost.valid?
  end

  # user_idが存在しているかどうかのテスト
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # content属性に対するバリデーションを追加（存在確認）
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # content属性に対するバリデーションを追加（文字数制限）
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  # DB上の最初のmicropostが、fixture内の most_recentと同じか検証するテスト
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
