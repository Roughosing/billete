class Organizations::EventsController < ApplicationController
  before_action :set_organization

  def index
    @events = @organization.events.order(starts_at: :desc)
  end

  def new
    @event = @organization.events.new
  end

  def create
    @event = @organization.events.new(event_params)

    if @event.save
      redirect_to organization_path, status: :see_other, notice: "Event created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Current.user.organization
  end

  def event_params
    params.expect(event: [ :title, :description, :location, :starts_at, :ends_at, :capacity, :price_cents ])
  end
end
