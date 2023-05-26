# frozen_string_literal: true

require 'net/http'
require 'json'
require 'cgi'
require 'base64'
require_relative './../../lib/pkce_generator'

class AuthController < ApplicationController
  before_action :set_client_id

  def authorize
    session[:code_verifier] = generate_code_verifier
    session[:code_challenge] = session[:code_verifier]
    redirect_to "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=#{@client_id}&code_challenge=#{session[:code_challenge]}",
                allow_other_host: true
    Rails.logger.debug("Code verifier: #{session[:code_verifier]}")
  end

  def callback
    uri = URI('https://myanimelist.net/v1/oauth2/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(
      'client_id' => @client_id,
      'client_secret' => @client_secret,
      'grant_type' => 'authorization_code',
      'code' => params[:code],
      'code_verifier' => session[:code_verifier]
    )

    response = http.request(request)
    token = JSON.parse(response.body)

    Rails.logger.debug("Authorization Server Response: #{response.body}")
    Rails.logger.debug("Access Token: #{token['access_token']}")
    Rails.logger.debug("Refresh Token: #{token['refresh_token']}")

    # Redirect to the index page with the access token and refresh token as query parameters
    redirect_to anime_path(access_token: token['access_token'], refresh_token: token['refresh_token'])
  end

  private

  def set_client_id
    @client_id = '6be21ec23d0ae17c9e20912aac6804b4'
    @client_secret = '050f45234aaeeea61bb5a1fec6a496141fea37c680781602d88ac1819a398d73'
    # @client_id = '2aea40e275bb5dd357450a98a120c3f9'
    # @client_secret = '24c2b43cd422dbe9c1a35a27a1e464426ba0f1c9ce516dc24f35bdc97038736a'
  end
end
