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
  end

  def error; end

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
    if response.code.to_i == 200
      token = JSON.parse(response.body)
      session[:access_token] = token['access_token']
      session[:refresh_token] = token['refresh_token']
      redirect_to anime_path
    else
      error_message = JSON.parse(response.body)['error_description']
      redirect_to error_path, alert: "Authentication failed: #{error_message}"
    end
  end

  private

  def access_token
    session[:access_token]
  end

  def refresh_token
    session[:refresh_token]
  end

  def set_client_id
    @client_id = ENV['MAL_CLIENT_ID']
    @client_secret = ENV['MAL_CLIENT_SECRET']
  end
end
