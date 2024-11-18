class App < Sinatra::Base

  def db
		return @db if @db

		@db = SQLite3::Database.new("db/media.sqlite")
		@db.results_as_hash = true

		return @db
	end

    get '/' do
        redirect('/media')
    end

    get '/media' do
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
      db.execute('INSERT INTO users (name, password) VALUES (?,?)', [params[:username], hashed_password])
      redirect('/media')
    end

    get '/login' do
      erb(:"login")
    end

    post '/login' do
      username = params['username']
      cleartext_password = params['password'] 

      #hämta användare och lösenord från databasen med hjälp av det inmatade användarnamnet.
      user = db.execute('SELECT * FROM users WHERE username = ?', username).first

      #omvandla den lagrade saltade hashade lösenordssträngen till en riktig bcrypt-hash
      password_from_db = BCrypt::Password.new(user['password'])

      #jämför lösenordet från databasen med det inmatade lösenordet
      if password_from_db == cleartext_password 
        session[:user_id] = user['id']
      end
    end


end
