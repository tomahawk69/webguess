require 'sinatra'
require 'sinatra/reloader'

#enable :sessions

configure :development do
      register Sinatra::Reloader
end

#configure do
#end

	use Rack::Session::Cookie, 
		:expire_after => 3600, # 1 hour
                :secret => "top webguess secret",
		:secure => true



MAXCOUNT = 7
WAYTOO = 10
VERSION = 3

get '/' do
  reset() if not session[:init] or not session[:version] or session[:version] != get_version()

  check_guess()  

  erb :index, :locals => {:session => session, 
	:is_cheat => is_cheat(), :maxcount => max_count(), :waytoo => waytoo()}
end

get '/reset' do
    reset()
    erb :reset
end

# functions

def check_guess
    session[:error] = ''
    return if is_done()
    if is_guess() then
	if params[:guess].gsub(/^\d{1,2}$/).count() == 0 then
	   session[:error] = "Bad or empty guess #{params[:guess]}"
	else
	   i = params[:guess].to_i - number()
	   if (i == 0) then
	      result = 'Correct!'
	      session[:done] = true
	      session[:color] = "LightGreen"
           else
              if (i > WAYTOO) then
	        session[:color] = "Red"
	        result = 'Way too high'
              elsif (i > 0) then
	        session[:color] = "OrangeRed"
	        result = 'Too high'
  	      elsif (i < -WAYTOO) then
	        session[:color] = "Red"
	        result = 'Way too low'
  	      elsif (i < 0) then
	        session[:color] = "OrangeRed"
	        result = 'Too low'
              end 
              if (session[:history].count() >= MAXCOUNT-1) then
	        session[:color] = "DarkRed"
	        session[:done] = true
                result << '. This was the last attempt.' 
              end 
	   end
	   session[:history][params[:guess]] = result if not session[:history].has_key?(params[:guess])
	end
    end
end

def number
    session[:number]
end

def is_done
    session[:done]
end

def is_guess
    (params[:guess] and not params[:guess].empty?)
end

def is_cheat
    (params[:cheat] and params[:cheat] == '1')
end

def get_version
   VERSION
end

def max_count
   MAXCOUNT
end

def waytoo
   WAYTOO
end

def reset
    session[:number] = rand(100)
    session[:history] = Hash.new()
    session[:number] = 99 if session[:number] == 100
    session[:done] = false
    session[:init] = true
    session[:color] = 'white'
    session[:version] = VERSION
end