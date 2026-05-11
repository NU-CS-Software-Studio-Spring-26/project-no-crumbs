require "net/http"
require "json"

class UnsplashService
  API_URL = "https://api.unsplash.com/search/photos"

  def self.fetch_photo_url(query)
    return nil if ENV["UNSPLASH_ACCESS_KEY"].blank?

    uri = URI(API_URL)
    uri.query = URI.encode_www_form(query: query, per_page: 1, orientation: "landscape")

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Client-ID #{ENV["UNSPLASH_ACCESS_KEY"]}"
      http.request(request)
    end

    return nil unless response.is_a?(Net::HTTPSuccess)

    results = JSON.parse(response.body).dig("results")
    results&.first&.dig("urls", "regular")
  rescue StandardError
    nil
  end
end
