Rails.application.routes.draw do
  get 'dummy/index'
  get 'dummy/protected'
  get 'dummy/show/:id' => 'dummy#show'
end
