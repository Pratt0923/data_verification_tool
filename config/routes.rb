Rails.application.routes.draw do
  root to: "email#index"
  get '/' => 'email#index'
  get '/emails', to: 'email#emails'
  get '/directmail', to: 'directmail#direct_mail'
  get '/clearemails', to: 'email#clear'
end
