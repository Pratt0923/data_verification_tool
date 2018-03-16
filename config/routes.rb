Rails.application.routes.draw do
  root to: 'pages#home'

  get '/uploads', to: 'pages#upload'
  get '/emails', to: 'email#emails'
  get '/directmail', to: 'directmail#index'
end
