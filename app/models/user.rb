class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_one :membership, dependent: :destroy
  has_one :organization, through: :membership

  normalizes :email_address, :unconfirmed_email, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validate :unconfirmed_email_is_available, if: :unconfirmed_email

  generates_token_for :email_confirmation, expires_in: 7.days do
    unconfirmed_email
  end

  def confirm_email
    update(email_address: unconfirmed_email, unconfirmed_email: nil)
  rescue ActiveRecord::RecordNotUnique
    errors.add(:email_address, "has already been taken")
    false
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def unconfirmed_email_is_available
    if User.where.not(id: id).exists?(email_address: unconfirmed_email)
      errors.add(:unconfirmed_email, "has already been taken")
    end
  end
end
