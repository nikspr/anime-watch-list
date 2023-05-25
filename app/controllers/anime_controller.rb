class AnimeController < ApplicationController
  def index
    response = HTTParty.get('https://api.myanimelist.net/v2/anime?q=Naruto')
    @anime = response.parsed_response
  end
end
