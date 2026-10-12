class Organizations::EventsController < ApplicationController
  before_action :set_organization

  def new
    @event = @organization.events.new
    @event.ticket_types.build(name: "General admission")
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
    redirect_to new_organization_path unless @organization
  end

  def event_params
    params.expect(event: [
      :title, :description, :location, :starts_at, :ends_at,
      ticket_types_attributes: [ [ :name, :description, :price, :quantity ] ]
    ])
  end
end
