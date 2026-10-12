class Event < ApplicationRecord
  belongs_to :organization
  has_many :tickets, dependent: :destroy
  has_many :ticket_types, -> { order(:position, :id) }, dependent: :destroy
  accepts_nested_attributes_for :ticket_types

  attribute :currency, default: "EUR"
  attribute :time_zone, default: -> { Time.zone.name }

  validates :title, :description, :location, :time_zone, :starts_at, :ends_at, :currency, presence: true
  validate :ends_after_start

  scope :upcoming, -> { where(ends_at: (Time.current..)) }
  scope :past, -> { where(ends_at: (nil...Time.current)) }

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start") if ends_at <= starts_at
  end
end
