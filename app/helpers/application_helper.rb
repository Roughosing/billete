module ApplicationHelper
  CURRENCY_SYMBOLS = { "EUR" => "€", "USD" => "$", "GBP" => "£" }.freeze

  # Lucide outline icons, read from app/assets/images/icons and inlined so they
  # inherit currentColor. Add one by dropping a 24×24 SVG in that directory.
  ICON_DIR = Rails.root.join("app/assets/images/icons")

  def icon(name, **options)
    tag.svg(icon_markup(name), **{
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      "stroke-width": 2,
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      "aria-hidden": true,
      focusable: false
    }.merge(options))
  end

  def initials(name)
    name.to_s.split.first(2).map { |part| part[0] }.join.upcase.presence || "?"
  end

  # Decorative initials badge. The letters are drawn with CSS from the data
  # attribute so they never leak into the surrounding element's text content.
  def avatar(name, size: nil)
    tag.span(class: [ "avatar", ("avatar-#{size}" if size) ], data: { initials: initials(name) }, "aria-hidden": true)
  end

  def currency_symbol(code)
    CURRENCY_SYMBOLS.fetch(code.to_s.upcase, "#{code} ")
  end

  def format_price(amount, currency = "EUR")
    return "Free" if amount.present? && amount.to_d.zero?

    number_to_currency(amount, unit: currency_symbol(currency))
  end

  # Lowest ticket price for an event, or nil when no ticket types exist yet.
  def starting_price(event)
    event.ticket_types.map(&:price).min
  end

  # :live while the event is happening, :upcoming before it starts, :ended after.
  def event_status(event, at: Time.current)
    if at >= event.ends_at
      :ended
    elsif at >= event.starts_at
      :live
    else
      :upcoming
    end
  end

  def event_status_badge(event)
    case event_status(event)
    when :live then tag.span("Live now", class: "badge badge-success badge-live")
    when :ended then tag.span("Ended", class: "badge")
    else tag.span("Upcoming", class: "badge badge-accent")
    end
  end

  def event_local(event, attribute = :starts_at)
    event.public_send(attribute).in_time_zone(event.time_zone)
  end

  # Renders a day/month chip. Used on cards and list rows.
  def date_chip(time)
    tag.span(class: "date-chip", "aria-hidden": true) do
      tag.b(time.strftime("%-d")) + tag.span(time.strftime("%b"))
    end
  end

  def pluralize_count(count, singular)
    "#{number_with_delimiter(count)} #{singular.pluralize(count)}"
  end

  private

  def icon_markup(name)
    path = ICON_DIR.join("#{name}.svg")
    raise ArgumentError, "No icon at #{path.relative_path_from(Rails.root)}" unless path.file?

    path.read[/<svg\b[^>]*>(.*)<\/svg>/m, 1].tap do |markup|
      raise ArgumentError, "#{path.relative_path_from(Rails.root)} has no <svg> root" if markup.nil?
    end.html_safe # rubocop:disable Rails/OutputSafety
  end
end
