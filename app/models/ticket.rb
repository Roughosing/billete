class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :ticket_type

  enum :status, { confirmed: "confirmed", cancelled: "cancelled" }, default: :confirmed, validate: true

  validates :code, :price, :currency, :issued_at, presence: true
  validates :code, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validate :ticket_type_matches_event
  validate :ticket_type_has_room, if: :claiming_place?

  before_validation :copy_sale_details, on: :create

  scope :upcoming, -> { confirmed.joins(:event).merge(Event.upcoming).order("events.starts_at") }
  scope :past, -> { confirmed.joins(:event).merge(Event.past).order("events.starts_at DESC") }

  private

  def copy_sale_details
    self.event ||= ticket_type.event if ticket_type
    assign_code
    self.issued_at ||= Time.current
    self.price = ticket_type.price if ticket_type && price.nil?
    self.currency = event.currency if event
  end

  def assign_code
    return if code.present?

    self.code = loop do
      candidate = SecureRandom.alphanumeric(10)
      break candidate unless Ticket.exists?(code: candidate)
    end
  end

  def ticket_type_matches_event
    return if ticket_type.blank? || event_id.blank?
    return if ticket_type.event_id == event_id

    errors.add(:ticket_type, "must belong to the event")
  end

  # A ticket takes a place when it is created confirmed, or when an existing
  # ticket moves back to confirmed (e.g. from cancelled).
  def claiming_place?
    confirmed? && (new_record? || will_save_change_to_status?)
  end

  def ticket_type_has_room
    return if ticket_type.blank?

    errors.add(:ticket_type, "is sold out") if ticket_type.remaining <= 0
  end
end
