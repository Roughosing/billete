class Event < ApplicationRecord
  belongs_to :organization

  attribute :currency, default: "EUR"
  attribute :time_zone, default: -> { Time.zone.name }

  validates :title, :description, :location, :time_zone, :starts_at, :ends_at, :capacity, :price_cents, :currency, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validate :ends_after_start

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start") if ends_at <= starts_at
  end
end
