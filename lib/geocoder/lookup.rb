require 'net/http'

module Geocoder
  module Lookup
    extend self

    ##
    # Query Google for the coordinates of the given address.
    # Returns array [lat,lon] if found, nil if not found or if network error.
    #
    def coordinates(address)
      return nil if address.blank?
      return nil unless doc = parsed_response(address, false)
      # blindly use first result (assume it is most accurate)
      place = doc['results'].first['geometry']['location']
      ['lat', 'lng'].map{ |i| place[i] }
    end

    ##
    # Query Google for the address of the given coordinates.
    # Returns string if found, nil if not found or if network error.
    #
    def address(latitude, longitude)
      return nil if latitude.blank? || longitude.blank?
      return nil unless doc = parsed_response("#{latitude},#{longitude}", true)
      # blindly use first result (assume it is most accurate)
      doc['results'].first['formatted_address']
    end

    ##
    # Query Google for geographic information about the given phrase.
    # Returns a Result object containing all data returned by Google.
    #
    def search(query, reverse = false)
      # TODO
    end


    private # ---------------------------------------------------------------

    ##
    # Returns a parsed Google geocoder search result (hash).
    # Returns nil if non-200 HTTP response, timeout, or other error.
    #
    def parsed_response(query, reverse = false)
      if doc = raw_response(query, reverse)
        doc = ActiveSupport::JSON.decode(doc)
        doc && doc['status'] == "OK" ? doc : nil
      end
    end

    ##
    # Returns a raw Google geocoder search result (JSON).
    #
    def raw_response(query, reverse = false)
      return nil if query.blank?

      # name parameter based on forward/reverse geocoding
      param = reverse ? :latlng : :address

      # build URL
      params = { param => query, :sensor  => "false" }
      url = "http://maps.google.com/maps/api/geocode/json?" + params.to_query

      # query geocoder and make sure it responds quickly
      begin
        resp = nil
        timeout(3) do
          Net::HTTP.get_response(URI.parse(url)).body
        end
      rescue SocketError, TimeoutError
        return nil
      end
    end
  end
end
