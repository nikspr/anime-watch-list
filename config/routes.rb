Rails.application.routes.draw do
  root to: redirect('https://www.niklaspringer.xyz')

  get '/authorize', to: 'auth#authorize'
  get '/callback', to: 'auth#callback'

  get '/anime', to: 'anime#index', as: 'anime'
  get '/manga', to: 'manga#index', as: 'manga'
end
