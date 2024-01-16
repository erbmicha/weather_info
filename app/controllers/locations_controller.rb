class LocationsController < ApplicationController
  before_action :find_location, only: %i(show)

  def index; end

  def create
    @location = Location.find_or_create_by!(location_params)

    redirect_to @location
  rescue ActiveRecord::RecordInvalid => e
    flash[:danger] = e.message

    redirect_to locations_path
  end

  def show
    @weather = WeatherService.call(latitude: @location.latitude, longitude: @location.longitude)
  rescue WeatherService::WeatherServiceError, JSON::ParserError => e
    flash[:danger] = e.message
    redirect_to locations_path
  end

  private

  def find_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:address)
  end
end
