require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path  #ログインページ移動
    assert_template 'sessions/new'  #ログインページのURL確認
    post login_path, params: { session: { email: "", password: "" } } #不正なログイン情報を送信
    assert_template 'sessions/new'  #ログインページのままになっていることを確認
    assert_not flash.empty? #エラーメッセージが出ているか
    get root_path #ルートページ移動
    assert flash.empty? #エラーメッセージが消えているか
  end

  test "login with valid information followed by logout" do
    get login_path  #ログインページ移動
    post login_path,params:{session: {email: @user.email,     #テストユーザーでログイン
                                      password: 'password'}}

    
    assert is_logged_in?
    assert_redirected_to @user  #ユーザーページにリダイレクトするか
    follow_redirect!    #実際にリダイレクトする
    assert_template 'users/show'    #ページがあっているか
    assert_select "a[href=?]", login_path, count: 0 #ログインのリンクが存在しないことを確認
    assert_select "a[href=?]", logout_path  #ログアウトのリンクが存在することを確認
    assert_select "a[href=?]", user_path(@user) #ユーザーのページが表示されていることを確認

    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0

  end
end
