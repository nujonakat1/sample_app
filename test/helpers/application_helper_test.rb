require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    # assert_equal <期待される値>, <実際の値>
    assert_equal "Ruby on Rails Tutorial Sample App", full_title
    #full_title == "Ruby on Rails Tutorial Sample App"の意味
    assert_equal "Help | Ruby on Rails Tutorial Sample App", full_title("Help")
    # assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Sample App"これでもいける！
    #full_title("Help") == "Help | Ruby on Rails Tutorial Sample App"の意味
  end
end
