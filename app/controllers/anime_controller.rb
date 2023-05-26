# frozen_string_literal: true

class AnimeController < ApplicationController
  PER_PAGE = 10

  def index
    page = params[:page].to_i
    offset = page * PER_PAGE

    url = URI.parse('https://api.myanimelist.net/v2/users/@me/animelist')
    headers = {
      'Authorization' => "Bearer #{session[:access_token]}"
    }

    params = {
      'fields' => 'list_status',
      'limit' => PER_PAGE,
      'offset' => offset
    }

    response = make_api_call(url, headers, params)
    if response.code.to_i == 200
      anime_list = JSON.parse(response.body)

      @anime_info_data = anime_list['data'].map do |anime|
        anime_id = anime['node']['id']
        get_anime_info(anime_id)
      end.compact
    else
      error_message = JSON.parse(response.body)['error_description']
      flash[:alert] = "Failed to fetch anime list: #{error_message}"
    end
  rescue StandardError => e
    flash[:alert] = "An error occurred: #{e.message}"
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
    Rails.cache.fetch("anime_info_#{anime_id}", expires_in: 12.hours) do
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
end
