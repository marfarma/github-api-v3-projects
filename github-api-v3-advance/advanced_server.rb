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
    
    CLIENT_ID = "6e5d2128179359d8af4f"
    CLIENT_SECRET = "8491370590272040442911a5565afb8324e32858"

    enable :sessions

    set :github_options, {
      :scopes        => "delete_repo",
      :secret       => CLIENT_SECRET,
      :client_id    => CLIENT_ID,
      :callback_url => "/callback?scope=repo" 
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

    get '/delete' do
      if !authenticated?
        authenticate!
      else
        name = params["name"]
        p name
        access_token = github_user["token"]
        # begin
          https = "https://api.github.com/repos/teddy-ma/#{name}"
          p "=================================================="
          p https
          p access_token
          auth_result = RestClient.delete(https, {
            :params => {:access_token => access_token, :accept => :json},
            :accept => :json
          })
        # rescue => e
        #   e.response

        #   p "---------------------------"
        #   p e
        #   p e.response
        # end     
        # auth_result = JSON.parse(auth_result)

        redirect '/repos'
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
