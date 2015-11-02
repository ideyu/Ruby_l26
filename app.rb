require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'The best!!!'
end

get '/login/form' do
  erb :login_form
end

get '/about' do
  @error = 'EROOOOOORRRR'
  erb :about
end

get '/schedule' do
  erb :schedule
end

get '/visit' do
  erb :visit
end

get '/contacts' do
  erb :contacts
end

post '/visit' do
  @name = params[:user_name]
  @phone = params[:user_phone]
  @date = params[:user_date]
  @barber = params[:barber]
  @color = params[:color]

  f = File.open './public/users.txt', 'a'
  f.write "User: #{@name} Phone: #{@phone} Date & Time: #{@date} Barber: #{@barber}\n"
  f.close

  hh = { :user_name => 'Введите имя', 
         :user_phone => 'Введите телефон',
         :user_date => 'Введите дату и время'}

  hh.each do |key,value|
    if params[key] == ''
      @error = hh[key]
      return erb :visit
    end
  end
  erb "#{@name} #{@phone} #{@date} #{@barber} #{@color}"
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
