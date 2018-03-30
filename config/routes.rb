Rails.application.routes.draw do
  root to: 'pages#home'
  get '/epick', to: 'emails#email_merge_variables_pick'
  get '/dmpick', to: 'emails#dm_merge_variables_pick'
  get '/emails', to: 'emails#emails'
  get '/directmails', to: 'direct_mails#direct_mail'
  get '/clearemails', to: 'emails#clear'
end
