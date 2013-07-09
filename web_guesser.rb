require 'sinatra'
require 'sinatra/reloader'

configure do
    set :number, rand(100)
    set :maxcount, 5
    set :count, 0
end

get '/' do
  guess = (params[:guess] and not params[:guess].empty?)
  ok = (guess and params[:guess].gsub(/^\d+$/).count() == 1)
  if ok then
	if settings.count >= settings.maxcount then
          last_attempt = true
	  result = 0
        else 
  	  result = params[:guess].to_i - settings.number
          last_attempt = false
	  settings.count += 1
        end
  else
	result = 0
  end  
  erb :index, :locals => {:number => settings.number, :is_cheating => (params[:cheat] && params[:cheat] == 'true'), :guess => guess, :ok => ok, :result => result, 
	:count => settings.count, :maxcount => settings.maxcount, :last_attempt => last_attempt}
#  if ok then
#	settings.count += 1
#  end
end

get '/reset' do
    settings.number = rand(100)
    settings.count = 0
    erb :reset
end