require 'sqlite3'

class Seeder

    def self.seed!
        drop_tables
        create_tables
        populate_tables
    end

    def self.drop_tables
        db.execute('DROP TABLE IF EXISTS media')
    end

    def self.create_tables
        db.execute('CREATE TABLE media (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    description TEXT,
                    poster TEXT,
                    backdrop TEXT,
                    rating FLOAT)')
    end

    def self.populate_tables
        movies = JSON.parse(File.read('db/popular_movies.json'))
        movies.each { |n| 
        db.execute('INSERT INTO media (title, description, poster, backdrop, rating) VALUES (?,?,?,?,?)', [n["title"], n["overview"], n["poster_path"], n["backdrop_path"], n["vote_average"].to_f])
        }
    end

    private
    def self.db
        return @db if @db
        @db = SQLite3::Database.new('db/media.sqlite')
        @db.results_as_hash = true
        @db
    end
end

Seeder.seed!