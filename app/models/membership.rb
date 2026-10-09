class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { staff: "staff", admin: "admin" }, default: :staff, validate: true

  validates :user, uniqueness: true
end
