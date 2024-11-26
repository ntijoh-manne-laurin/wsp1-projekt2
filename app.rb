require 'sinatra'
require 'securerandom'

class App < Sinatra::Base

  def db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  get '/' do
    redirect('/media')
  end

  get '/media' do
    user_id = session[:user_id]
    p user_id
    @user = db.execute('SELECT * FROM users WHERE id=?', user_id).first
    if @user.nil?
      # redirect('/login')
      p "inte inloggad"
    end

    @media = db.execute('SELECT * FROM media')
    erb(:"index")
  end

  post '/media' do
    p params
    db.execute('INSERT INTO media (title, description) VALUES (?,?)', [params['title'], params['description']])
    redirect('/media')
  end

  post '/media/:id/delete' do |id|
    db.execute('DELETE FROM media WHERE id=?', id)
    redirect('/media')
  end

  get '/media/new' do 
    erb(:"media/new")
  end

  get '/media/:id' do |id|
    @user = db.execute('SELECT * FROM users WHERE id=?', session[:user_id]).first
    @media = db.execute('SELECT * FROM media WHERE id=?', id).first
    #todo: om media inte finns gör nåt (.nil?)
    erb(:"media/show")
  end

  get '/register' do
    erb(:"register")
  end

  post '/register' do
    p params
    cleartext_password = params['password'] 
    hashed_password = BCrypt::Password.create(cleartext_password)
    db.execute('INSERT INTO users (username, password) VALUES (?,?)', [params[:username], hashed_password])
    
    redirect('/login')
  end

  get '/login' do
    erb(:"login")
  end

  post '/login' do
    username = params['username']
    cleartext_password = params['password']

    #hämta användare och lösenord från databasen med hjälp av det inmatade användarnamnet.
    user = db.execute('SELECT * FROM users WHERE username=?', username).first
    p user

    db_id = user["id"].to_i
    db_password_hashed = user["password"].to_s

    #omvandla den lagrade saltade hashade lösenordssträngen till en riktig bcrypt-hash
    password_from_db = BCrypt::Password.new(db_password_hashed)

    #jämför lösenordet från databasen med det inmatade lösenordet
    if password_from_db == cleartext_password 
      p "rätt lösen"
      session[:user_id] = user['id']
      p user['id']
      p session[:user_id]
      redirect('/media')
    else
      status 401
      erb(:"login")
    end
  end

  post '/rating/:id' do |id|
    p params
    user_id = session[:user_id]
    rating = db.execute('SELECT * FROM ratings WHERE user_id=? AND media_id=?', [user_id, id]).first
    if rating.nil?
      db.execute('INSERT INTO ratings (user_id, media_id, score) VALUES (?,?,?)', [user_id, id, params['rating']])
    else
      db.execute('UPDATE ratings SET score=? WHERE user_id=? AND media_id=?', [params['rating'].to_i, user_id, id])
    end
    redirect('/media')
  end

end
