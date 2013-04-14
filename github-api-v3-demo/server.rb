require 'sinatra'
require 'rest-client'
require 'json'

CLIENT_ID = "23b61613131b4d473eb6"
CLIENT_SECRET = "6ef41173e764159d25cf05a20af53eef2260dde8"

get '/' do 
  erb :index, :locals => {:client_id => CLIENT_ID}
end

get '/callback' do
  # get temporary GitHub code...
  session_code = request.env['rack.request.query_hash']["code"]
  # ... and POST it back to GitHub
  result = RestClient.post("https://github.com/login/oauth/access_token",
			  {
			   :client_id => CLIENT_ID,
			   :client_secret => CLIENT_SECRET,
			   :code => session_code
			  },
			  {:accept => :json}
			  )
  access_token = JSON.parse(result)["access_token"]
  auth_result = RestClient.get("https://api.github.com/user", {:params => {:access_token => access_token}})
  p auth_result
  erb :basic, :locals => {:auth_result => auth_result}
end
