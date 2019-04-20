Radiant::Engine.routes.draw do
  root to: "site#show_page"
  get "*url", to: 'site#show_page'
end
