require_relative '../whales/whales_actions/lib/whales_controller/base'

def make_router
  router = WhalesDispatch::Router.new

  router.draw do
    # include routes using this syntax:
    # get Regexp.new("^/users/new$"), UsersController, :new
    # or
    # resources :users, :parent, only: [:new]
    #
    # nested resources are given as blocks to :parent resources
    # resources :posts, :parent do
    #   resources :comments, :nested, only: [:index, :new, :create]
    # end
  end

  router
end
