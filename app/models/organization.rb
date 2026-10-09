class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :events, dependent: :destroy

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true

  def self.create_with_admin(user, attributes)
    transaction do
      create!(attributes).tap do |organization|
        organization.memberships.create!(user: user, role: :admin)
      end
    end
  rescue ActiveRecord::RecordInvalid => error
    error.record.is_a?(Organization) ? error.record : new(attributes).tap { |organization|
      organization.errors.add(:base, error.record.errors.full_messages.to_sentence)
    }
  end
end
