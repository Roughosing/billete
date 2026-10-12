class TicketType < ApplicationRecord
  belongs_to :event
  has_many :tickets, dependent: :destroy

  validates :name, :price, :quantity, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :sales_end_after_start
  validate :quantity_covers_issued_tickets, on: :update

  scope :ordered, -> { order(:position, :id) }
  scope :on_sale, ->(at = Time.current) {
    where("sales_starts_at IS NULL OR sales_starts_at <= ?", at)
      .where("sales_ends_at IS NULL OR sales_ends_at > ?", at)
  }
  scope :available, -> {
    on_sale.where(
      "quantity > (SELECT COUNT(*) FROM tickets WHERE tickets.ticket_type_id = ticket_types.id AND tickets.status = ?)",
      Ticket.statuses[:confirmed]
    )
  }

  def remaining
    quantity - tickets.confirmed.count
  end

  # Issues a ticket while holding a row lock on this ticket type, so two
  # buyers racing for the last place are serialised by PostgreSQL: the second
  # transaction waits for the first to commit, then sees the updated count and
  # fails validation. Always create tickets through here; a bare
  # `tickets.create!` is subject to the check-then-insert race.
  def issue!(user:, **attributes)
    with_lock do
      tickets.create!(user: user, **attributes)
    end
  end

  private

  def sales_end_after_start
    return if sales_starts_at.blank? || sales_ends_at.blank?

    errors.add(:sales_ends_at, "must be after the start") if sales_ends_at <= sales_starts_at
  end

  def quantity_covers_issued_tickets
    return if quantity.blank?

    issued = tickets.confirmed.count
    errors.add(:quantity, "must cover tickets already issued") if quantity < issued
  end
end
