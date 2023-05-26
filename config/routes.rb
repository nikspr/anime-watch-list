# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  get '/authorize', to: 'auth#authorize'
  get '/callback', to: 'auth#callback'

  get '/anime', to: 'anime#index', as: 'anime'
  get '/manga', to: 'manga#index', as: 'manga'
end
