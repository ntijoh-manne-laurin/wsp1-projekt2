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


end
