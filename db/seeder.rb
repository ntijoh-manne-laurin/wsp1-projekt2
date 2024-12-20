require 'sqlite3'

class Seeder

    def self.seed!
       drop_tables
       create_tables
       populate_tables
    end

    def self.drop_tables
        db.execute('DROP TABLE IF EXISTS media')
        db.execute('DROP TABLE IF EXISTS users')
        db.execute('DROP TABLE IF EXISTS ratings')
        db.execute('DROP TABLE IF EXISTS added_media')
    end

    def self.create_tables
        db.execute('CREATE TABLE media (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    description TEXT NOT NULL,
                    poster TEXT,
                    backdrop TEXT NOT NULL,
                    rating FLOAT NOT NULL,
                    vote_count INTEGER NOT NULL,
                    owner_id INTEGER)')
                    
        db.execute('CREATE TABLE users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT NOT NULL,
                    password TEXT NOT NULL)')

        db.execute('CREATE TABLE ratings (
                    user_id INTEGER NOT NULL,
                    media_id INTEGER NOT NULL,
                    score INTEGER NOT NULL)')
    end

    def self.populate_tables
        movies = JSON.parse(File.read('db/popular_movies.json'))
        movies.each { |n| 
        db.execute('INSERT INTO media (title, description, poster, backdrop, rating, vote_count) VALUES (?,?,?,?,?,?)', [n["title"], n["overview"], "https://image.tmdb.org/t/p/w500/#{n["poster_path"]}", "https://image.tmdb.org/t/p/w500/#{n["backdrop_path"]}", n["vote_average"].to_f, n["vote_count"]])
        }

        password_hashed = BCrypt::Password.create("banan")
        db.execute('INSERT INTO users (username, password) VALUES (?,?)',["Manne", password_hashed])
    end

    private
    def self.db
        return @db if @db
        @db = SQLite3::Database.new('db/data.sqlite')
        @db.results_as_hash = true
        @db
    end
end

Seeder.seed!