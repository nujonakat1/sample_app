class User < ApplicationRecord
  # マイクロポストもユーザーの削除と一緒に破棄（削除）
  has_many :microposts, dependent: :destroy

  #仮想の属性:remember_token、activation_tokenをUserクラスに定義
  # attr_accessor :remember_token, :activation_token
  attr_accessor :remember_token, :activation_token, :reset_token
  # before_save { self.email = email.downcase }     #右側のselfは省略できるんだけど左側は不可
  # before_save { email.downcase! }   # ブロック
  #保存の直前に参照するメソッド
  before_save   :downcase_email   # メソッド参照
  # データ作成の直前に参照するメソッド
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  # validates :password, presence: true, length: { minimum: 6 }
  # 空だったときの例外処理を追加
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  # 渡された文字列のハッシュ値を返す
  # def User.digest(string)
  def self.digest(string)   # selfを使う
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  # def User.new_token
  def self.new_token    # selfを使う
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # 記憶トークンを作成
    self.remember_token = User.new_token
    #User.digestを適用した結果で記憶ダイジェストを更新
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  # 有効だった場合、ユーザーを認証してから activated_at タイムスタンプを更新
  def activate
    # user.update_attribute(:activated,    true)
    # update_attribute(:activated,    true)
    # user.update_attribute(:activated_at, Time.zone.now)
    # update_attribute(:activated_at, Time.zone.now)
    # (注) update_columns は、バリデーションとモデルのコールバックが実行されない
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # UserMailer.account_activation(@user).deliver_now
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    Micropost.where("user_id = ?", id)
  end

  private   # private キーワード

    # メールアドレスをすべて小文字にする
    def downcase_email
      # self.email = email.downcase
      self.email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
