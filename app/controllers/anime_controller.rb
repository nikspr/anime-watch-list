class AnimeController < ApplicationController
  def index
    url = URI.parse('https://api.myanimelist.net/v2/users/@me/animelist')
    headers = {
      'Authorization' => "Bearer #{session[:access_token]}"
    }

    per_page = 100
    offset = 0
    @anime_list_data = []

    begin
      loop do
        params = {
          'fields' => 'list_status',
          'limit' => per_page,
          'offset' => offset
        }

        response = make_api_call(url, headers, params)
        if response.code.to_i == 200
          anime_list = JSON.parse(response.body)
          break if anime_list['data'].empty?

          @anime_list_data.concat(anime_list['data'])
          offset += per_page
        else
          error_message = JSON.parse(response.body)['error_description']
          raise StandardError, "Failed to fetch anime list: #{error_message}"
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error occurred in AnimeController#index: #{e.message}")
      e.backtrace.each { |trace| Rails.logger.error(trace) }
      redirect_to error_path, alert: "An error occurred while fetching anime list. Please try again later."
      return
    end
  end

  private

  def make_api_call(url, headers, params = {})
    uri = URI(url)
    params['sort'] = 'list_score'
    uri.query = URI.encode_www_form(params) unless params.empty?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    headers.each do |key, value|
      request[key] = value
    end

    response = http.request(request)
    unless response.code == '200'
      raise StandardError, "API request failed with status code #{response.code}"
    end
    response
  end
end
