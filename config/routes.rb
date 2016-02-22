# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#match 'doc_pu', :controller => 'doc_pu' # , :action => 'order_blocks', :via => :post
#match '/doc_pu' => 'doc_pu#index' #, :action => 'order_blocks', :via => :post
get 'doc_pu' => 'doc_pu#index' #, :action => 'order_blocks', :via => :post
#get 'doc_pu', :to => 'doc_pu#index'
#match '/doc_pu/new', :controller=> 'doc_pu', :action => 'new', :via => :get
match '/doc_pu(/:action)', :controller => 'doc_pu', :via => [:get, :post, :put]
match '/doc_pu_wiki(/:action)', :controller => 'doc_pu_wiki' , :via => [ :get, :post, :put ]
