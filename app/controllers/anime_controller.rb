class AnimeController < ApplicationController
  def index
    @access_token = params[:access_token]
    @refresh_token = params[:refresh_token]
    url = URI.parse('https://api.myanimelist.net/v2/users/@me/animelist')
    headers = {
      'Authorization' => "Bearer #{@access_token}"
    }

    per_page = 100
    offset = 0
    @anime_list_data = []

    loop do
      params = {
        'fields' => 'list_status',
        'limit' => per_page,
        'offset' => offset
      }

      response = make_api_call(url, headers, params)
      anime_list = JSON.parse(response.body)
      break if anime_list['data'].empty?

      @anime_list_data.concat(anime_list['data'])
      offset += per_page
    end
  end

  private

  def make_api_call(url, headers, params = {})
    uri = URI(url)
    params['sort'] = 'list_score' # Add the sort parameter with value list_score
    uri.query = URI.encode_www_form(params) unless params.empty?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    headers.each do |key, value|
      request[key] = value
    end

    response = http.request(request)

    raise "Failed to make API call: #{response.body}" unless response.code == '200'

    response
  end
end
