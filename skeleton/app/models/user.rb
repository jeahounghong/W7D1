# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_name       :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#
class User < ApplicationRecord
    after_initialize :ensure_session_token

    validates :user_name, :session_token, presence: true, uniqueness: true
    validates :password_digest, presence: true
    validates :password, length: { minimum: 6 }, allow_nil: true

    attr_reader :password

    has_many :cats,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: :Cat

    has_many :requests,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: :CatRentalRequest

    def self.find_by_credentials(user_name, password)
        user = User.find_by(user_name: user_name)
        if user && user.is_password?(password)
            user
        else
            nil
        end
    end
    
    def generate_session_token
        SecureRandom::urlsafe_base64(16)
    end

    def ensure_session_token
        self.session_token ||= self.generate_session_token
    end

    def reset_session_token!
        self.session_token = self.generate_session_token
        self.save!
        self.session_token
    end

    def password=(password)
        @password = password
        self.password_digest =BCrypt::Password.create(password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end
end
