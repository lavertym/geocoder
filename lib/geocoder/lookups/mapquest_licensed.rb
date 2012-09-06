require 'geocoder/lookups/base'
require "geocoder/results/mapquest_licensed"

module Geocoder::Lookup
  class MapquestLicensed < Base

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
      begin
        doc = doc['results'][0]['locations']
      rescue
        return []
      end
      doc.is_a?(Array) ? doc : [doc]
    end

    def query_url(query, reverse = false)
      params = {
        :format => "json",
        :"accept-language" => Geocoder::Configuration.language,
        :key => Geocoder::Configuration.api_key,
        :maxResults=>1
      }
      if (reverse)
        method = 'reverse'
        parts = query.split(/\s*,\s*/);
        params[:lat] = parts[0]
        params[:lon] = parts[1]
      else
        method = 'search'
        params[:location] = query
      end
      url = "http://www.mapquestapi.com/geocoding/v2/address?" + hash_to_query(params)
      Rails.logger.info url
      url

    end
  end
end
