Rails.application.routes.draw do
  root to: 'auth#authorize'
  get '/authorize', to: 'auth#authorize'
  get '/callback', to: 'auth#callback'
  get '/anime', to: 'anime#index', as: 'anime'

end
