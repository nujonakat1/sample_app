class User < ApplicationRecord

  #仮想の属性:remember_token、activation_tokenをUserクラスに定義
  attr_accessor :remember_token, :activation_token
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
