require 'geocoder/results/base'

module Geocoder::Result
  class MapquestLicensed < Base

    def house_number
      @data['address']['house_number']
    end

    def address
      @data['display_name']
    end

    def street
      @data['street']
    end

    def city
      @data['adminArea5']
    end

    alias_method :village, :city
    alias_method :town, :city

    def state
      @data['adminArea3']
    end

    alias_method :state_code, :state

    def postal_code
      @data['postalCode']
    end

    def county
      @data['adminArea4']
    end

    def country
      @data['adminArea1']
    end

    alias_method :country_code, :country

    def coordinates
      [@data['latLng']['lat'].to_f, @data['latLng']['lng'].to_f]
    end

    def self.response_attributes
      %w[place_id boundingbox license polygonpoints display_name class type stadium suburb]
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
