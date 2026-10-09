class EventsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    # Replace with published events once the Event model exists.
    @events = []
  end

  def show
  end
end
