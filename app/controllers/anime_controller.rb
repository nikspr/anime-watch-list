# frozen_string_literal: true

class AnimeController < ApplicationController
  def index
    url = URI.parse('https://api.myanimelist.net/v2/users/@me/animelist')
    headers = {
      'Authorization' => "Bearer #{session[:access_token]}"
    }

    per_page = 100
    offset = 0
    @anime_list_data = []
    @anime_info_data = [] # Add this line to initialize @anime_info_data

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
          flash[:alert] = "Failed to fetch anime list: #{error_message}" # Use flash[:alert] instead of redirecting
          break # Break the loop if an error occurs
        end
      end
    rescue StandardError => e
      flash[:alert] = "An error occurred: #{e.message}" # Use flash[:alert] instead of redirecting
    end

    @anime_list_data.each do |anime|
      anime_id = anime['node']['id']
      anime_info = get_anime_info(anime_id)

      # Add the detailed anime information to the array
      @anime_info_data << anime_info if anime_info
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
    raise StandardError, "API request failed with status code #{response.code}" unless response.code == '200'

    response
  end

  def get_anime_info(anime_id)
    url = URI.parse("https://api.myanimelist.net/v2/anime/#{anime_id}?fields=id,title,main_picture,start_date,end_date,synopsis,mean,rank,media_type,status,genres,my_list_status,rating")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)

    # Add any necessary headers, such as authorization if required
    request['Authorization'] = "Bearer #{session[:access_token]}"

    response = http.request(request)

    if response.code.to_i == 200
      JSON.parse(response.body)
      # Process and use the anime data as needed
    else
      # Handle error case
      nil
    end
  end
end
