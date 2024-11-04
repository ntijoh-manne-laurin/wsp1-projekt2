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

    get '/media/:id' do |id|
        @media = db.execute('SELECT * FROM media WHERE id=?', id)
        erb(:"media/show")
    end

end
