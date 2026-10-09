class EventsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @events = Event.where(starts_at: Time.current..).order(starts_at: :asc)
  end

  def show
    @event = Event.find(params[:id])
  end
end
