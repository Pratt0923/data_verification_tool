Rails.application.routes.draw do
  root to: "email#index"
  get '/' => 'email#index'
  get '/emails', to: 'email#emails'
  get '/directmail', to: 'directmail#index'
end
