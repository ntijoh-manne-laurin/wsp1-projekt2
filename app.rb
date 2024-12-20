require 'sinatra'
require 'securerandom'

class App < Sinatra::Base

  def db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  before do 
    @user = db.execute('SELECT * FROM users WHERE id=?', session[:user_id]).first
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  get '/' do
    redirect('/media')
  end

  get '/media' do
    if @user.nil?
      # redirect('/login')
      p "inte inloggad"
    end

    @media = db.execute('SELECT * FROM media')
    erb(:"index")
  end

  
  post '/media/delete/:id' do |id|
    correct_user = !db.execute('SELECT * FROM media WHERE owner_id=? AND id=?', [@user['id'], id]).first.nil?
    if correct_user
      db.execute('DELETE FROM media WHERE id=?', id)
      db.execute('DELETE FROM ratings WHERE media_id=?', id)
      redirect('/media')
    else #inte rätt användare
      #säg åt användaren att hen inte får ta bort denna media
      redirect('/media')
    end
  end
  
  get '/media/new' do 
    erb(:"media/new")
  end
  
  post '/media/new' do
    # p params
    media_id = db.execute('INSERT INTO media (title, description, backdrop, rating, vote_count, owner_id) VALUES (?,?,?,?,?,?) RETURNING id', [params['title'], params['description'], params['backdrop'], params['rating'].to_i, 1, @user['id']]).first['id']
    #media_id = db.execute('SELECT id FROM media WHERE title=?', params['title']).first[:id]
    p @user['id']
    p media_id
    p params['rating'].to_i
    db.execute('INSERT INTO ratings (user_id, media_id, score) VALUES (?,?,?)', [@user['id'], media_id.to_i, params['rating'].to_i])
    # db.execute('INSERT INTO added_media (user_id, media_id) VALUES (?,?)', [session[:user_id], media_id.to_i])
    redirect('/media')
  end

  post '/media/edit/:id' do |id|
    p params
    #Hämta det nuvarande betyget som användaren har gett denna media
    rating = db.execute('SELECT * FROM ratings WHERE user_id=? AND media_id=?', [@user['id'], id]).first
    #Hämta antalet röster och snittligt resultat för denna media
    vote_average = db.execute('SELECT rating FROM media WHERE id=?', [id]).first['rating']
    vote_count = db.execute('SELECT vote_count FROM media WHERE id=?', [id]).first['vote_count']

    new_rating = (vote_average*(vote_count-1) + params['rating'].to_i)/(vote_count)
    db.execute('UPDATE ratings SET score=? WHERE user_id=? AND media_id=?', [params['rating'].to_i, @user['id'], id])
    db.execute('UPDATE media SET title=?, description=?, backdrop=?, rating=? WHERE id=?', [params['title'], params['description'], params['backdrop'], new_rating, id])
    redirect('/media/'+id)
  end

  get '/media/edit/:id' do |id|
    @media = db.execute('SELECT * FROM media WHERE id=?', id).first
    @rating = db.execute('SELECT * FROM ratings WHERE media_id=?', id).first
    erb(:"media/edit")
  end

  get '/media/user_ratings' do 
    @media = db.execute('SELECT *   
                        FROM media 
                        INNER JOIN ratings 
                          ON media.id = ratings.media_id
                        WHERE ratings.user_id=?', [@user['id']])
    erb(:"media/user_rated")
  end

  get '/media/user_media' do
    @media = db.execute('SELECT * FROM media WHERE media.owner_id=?', [@user['id']])
    erb(:"media/user_media")
  end
  
  get '/media/:id' do |id|
    @media = db.execute('SELECT * FROM media WHERE id=?', id).first
    p @media
    @rating = db.execute('SELECT * FROM ratings WHERE media_id=? AND user_id=?', [@media['id'], @user['id']]).first
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

  get '/logout' do
    session.clear 
    redirect('/media')
  end

  post '/rating/:id' do |id|
    p params
    user_id = session[:user_id]
    #Hämta det nuvarande betyget som användaren har gett denna media
    rating = db.execute('SELECT * FROM ratings WHERE user_id=? AND media_id=?', [user_id, id]).first
    #Hämta antalet röster och snittligt resultat för denna media
    vote_average = db.execute('SELECT rating FROM media WHERE id=?', [id]).first['rating']
    vote_count = db.execute('SELECT vote_count FROM media WHERE id=?', [id]).first['vote_count']
    p vote_average
    p vote_count
    # Om det är första gången användaren ger denna media en rating, öka i så fall antalet röster och 
    # beräkna det nya betyget, annars beräkna bara det nya betyget och uppdatera det sedan.
    if rating.nil?
      new_rating = (vote_average * vote_count + params['rating'].to_i)/(vote_count + 1)
      db.execute('INSERT INTO ratings (user_id, media_id, score) VALUES (?,?,?)', [user_id, id, params['rating'].to_i])
      db.execute('UPDATE media SET rating=?, vote_count=? WHERE id=?', [new_rating, (vote_count + 1), id])
    else
      new_rating = (vote_average*(vote_count-1) + params['rating'].to_i)/(vote_count)
      db.execute('UPDATE ratings SET score=? WHERE user_id=? AND media_id=?', [params['rating'].to_i, user_id, id])
      db.execute('UPDATE media SET rating=? WHERE id=?', [new_rating, id])
    end
    redirect('/media')
  end

end
