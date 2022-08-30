Rails.application.routes.draw do
  root 'homepage#index'
  post '/', to: 'url#shorten'
  get '/:url', to: 'url#redirect'
end
