class AnimeController < ApplicationController
  def index
    access_token = params[:access_token]
    refresh_token = params[:refresh_token]

    # Make API call to retrieve the user's anime list
    anime_list_response = make_api_call(access_token, '/anime_list_endpoint')
    anime_list_data = JSON.parse(anime_list_response.body)

    # Fetch the anime list and display basic information
    @anime_list = fetch_anime_list(anime_list_data)

    # Make API call to retrieve the user's manga list
    manga_list_response = make_api_call(access_token, '/manga_list_endpoint')
    manga_list_data = JSON.parse(manga_list_response.body)

    # Fetch the manga list and display basic information
    @manga_list = fetch_manga_list(manga_list_data)
  end

  private

  def make_api_call(access_token, endpoint)
    username = 'nikitaku'
    uri = URI("https://api.myanimelist.net/v2/users/#{username}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path)
    request['Authorization'] = "Bearer #{access_token}"

    http.request(request)
  end

  def fetch_anime_list(anime_list_data)
  puts anime_list_data.inspect # Debugging statement
  return [] unless anime_list_data && anime_list_data['data']

  anime_list_data['data'].map do |anime|
    {
      title: anime['node']['title']
    }
  end
end

def fetch_manga_list(manga_list_data)
  puts manga_list_data.inspect # Debugging statement
  return [] unless manga_list_data && manga_list_data['data']

  manga_list_data['data'].map do |manga|
    {
      title: manga['node']['title']
    }
  end
end

end
