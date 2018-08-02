Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'pages#home'
  get '/epick', to: 'emails#email_merge_variables_pick'
  post '/emails', to: 'emails#emails'
  get '/dmpick', to: 'direct_mails#dm_merge_variables_pick'
  get '/emails', to: 'emails#emails'
  get '/directmails', to: 'direct_mails#direct_mail'
  get '/clearemails', to: 'emails#clear'
  get '/select', to: 'emails#select'
  get '/spellcheck', to: 'emails#spellcheck'
  resources :emails
  
end
