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
                    description TEXT)')
    end

    def self.populate_tables
        db.execute('INSERT INTO media (title, description) VALUES ("Alien", "After investigating a mysterious transmission of unknown origin, the crew of a commercial spacecraft encounters a deadly lifeform.")')
        db.execute('INSERT INTO media (title, description) VALUES ("John Wick", "An assassin returns to his old job after his dog dies.")')
        db.execute('INSERT INTO media (title, description) VALUES ("The Dark Knight", "Orphan fights a clown.")')
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