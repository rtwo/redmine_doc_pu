# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#match 'doc_pu', :controller => 'doc_pu' # , :action => 'order_blocks', :via => :post
match '/doc_pu' => 'doc_pu#index' #, :action => 'order_blocks', :via => :post
#get 'doc_pu', :to => 'doc_pu#index'
