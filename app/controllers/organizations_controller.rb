class OrganizationsController < ApplicationController
  before_action :redirect_member_to_organization, only: %i[ new create ]
  before_action :set_organization, only: %i[ show edit update ]
  before_action :require_admin, only: %i[ edit update ]
  layout "organization", only: %i[ show edit update ]

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.create_with_admin(Current.user, organization_params)

    if @organization.persisted?
      redirect_to organization_path, status: :see_other, notice: "Your organization was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    events = @organization.events
    @events = events.includes(:ticket_types).order(starts_at: :desc)
    @upcoming_count = events.upcoming.count
    @capacity = TicketType.where(event_id: events.select(:id)).sum(:quantity)
    @tickets_by_event = Ticket.confirmed.where(event_id: events.select(:id)).group(:event_id).count
    @tickets_issued = @tickets_by_event.values.sum
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to edit_organization_path, status: :see_other, notice: "Your organization was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def redirect_member_to_organization
    redirect_to organization_path if Current.user.organization
  end

  def set_organization
    @organization = Current.user.organization
    redirect_to new_organization_path unless @organization
  end

  def require_admin
    unless Current.user.membership.admin?
      redirect_to organization_path, alert: "Only an admin can change the organization."
    end
  end

  def organization_params
    params.expect(organization: [ :name ])
  end
end
