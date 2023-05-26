# frozen_string_literal: true

class MangaController < ApplicationController
  PER_PAGE = 12
  def index
    page = params[:page].to_i
    offset = page * PER_PAGE

    url = URI.parse('https://api.myanimelist.net/v2/users/@me/mangalist')
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
      manga_list = JSON.parse(response.body)

      @manga_info_data = manga_list['data'].map do |manga|
        manga_id = manga['node']['id']
        get_manga_info(manga_id)
      end.compact

      total_items = manga_list['paging']['total_items'].to_f
      @total_pages = (total_items / PER_PAGE).ceil
    else
      error_message = JSON.parse(response.body)['error_description']
      flash[:alert] = "Failed to fetch manga list: #{error_message}"
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

  def get_manga_info(manga_id)
    Rails.cache.fetch("manga_info_#{manga_id}", expires_in: 12.hours) do
      url = URI.parse("https://api.myanimelist.net/v2/manga/#{manga_id}?fields=id,title,main_picture,start_date,synopsis,mean,media_type,status,genres,my_list_status,authors{first_name,last_name}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url)

      request['Authorization'] = "Bearer #{session[:access_token]}"

      response = http.request(request)

      if response.code.to_i == 200
        JSON.parse(response.body)
        # Process and use the manga data as needed
      else
        # Handle error case
        nil
      end
    end
  end
end
