require 'sinatra/auth/github'
require 'rest-client'

module Example
  class MyBasicApp < Sinatra::Base
    # !!! DO NOT EVER USE HARD-CODER VALUES IN A REAL APP !!!
    # Instead, set and test environment variables, like below
    # if ENV['GITHUB_CLIENT_ID'] && ENV['GITHUB_CLIENT_ID']
    #   CLIENT_ID     = ENV['GITHUB_CLIENT_ID']
    #   CLIENT_SECRET = ENV['GITHUB_CLIENT_SECRET']
    # end
    
    CLIENT_ID = "23b61613131b4d473eb6"
    CLIENT_SECRET = "6ef41173e764159d25cf05a20af53eef2260dde8"

    enable :sessions

    set :github_options, {
      :scope        => "delete_repo",
      :secret       => CLIENT_SECRET,
      :client_id    => CLIENT_ID,
      :callback_url => "/callback" 
    }
    
    register Sinatra::Auth::Github

    get '/' do
      if !authenticated?
      	authenticate!
      else
        access_token = github_user["token"]
      	auth_result = RestClient.get("https://api.github.com/user", {
      	  :params => {:access_token => access_token, :accept => :json},
      	  :accept => :json
      	})
            	
      	auth_result = JSON.parse(auth_result)

      	erb :advanced, :locals => {:login => auth_result["login"],
      	:hire_status => auth_result["hireable"] ? "hireable" : "not hireable"}
      end
    end

    get '/repos' do
      if !authenticated?
        authenticate!
      else
        access_token = github_user["token"]
        # GET /users/:user/repos
        auth_result = RestClient.get("https://api.github.com/user/repos", {
          :params => {:access_token => access_token, :accept => :json, :sort => "updated", :per_page => 100},
          :accept => :json
        })
              
        auth_result = JSON.parse(auth_result)
        p auth_result.length
        repos = Array.new
        auth_result.each do |repo|
          repos << repo["name"]
        end
        erb :repos, :locals => {:repos => repos} 
      end
    end

    get '/callback' do
      if authenticated?
	redirect "/"
      else
	authenticate!
      end
    end
  end
end
