class EventsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end
end
