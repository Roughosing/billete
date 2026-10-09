class OrganizationsController < ApplicationController
  before_action :redirect_member_to_organization, only: %i[ new create ]
  before_action :set_organization, only: %i[ show edit update ]
  layout "organization", only: %i[ show edit update ]

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.create_with_admin(Current.user, organization_params)

    redirect_to organization_path, status: :see_other, notice: "Your organization was created."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
    @events = @organization.events.order(starts_at: :desc)
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

  def organization_params
    params.expect(organization: [ :name ])
  end
end
