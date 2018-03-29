Rails.application.routes.draw do
  root to: 'pages#home'

  get '/emails', to: 'emails#emails'
  get '/directmails', to: 'direct_mails#direct_mail'
  get '/clearemails', to: 'emails#clear'
end
