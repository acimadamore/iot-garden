require 'sqlite3'

module IoTGarden
  class DB
    DATABASE_NAME = 'data/iot_garden.db'

    def self.query_db
      db = SQLite3::Database.new DATABASE_NAME, results_as_hash: true

      ret = yield db

      db.close

      ret
    end

    def self.all(table_name, order = 'ASC')
      query_db do |db|
        db.execute("SELECT * FROM #{table_name} ORDER BY uid #{order}")
      end
    end

    def self.find(table_name, id)
      query_db do |db|
        db.execute("SELECT * FROM #{table_name} WHERE uid = #{id}").first
      end
    end

    def self.get_environment_station
      query_db do |db|
        db.execute('SELECT * FROM environment_station LIMIT 1').first
      end
    end

    def self.update_water_station(uid, name, low_soil_humidity, high_soil_humidity, watering_time)
      query_db do |db|
        db.execute('UPDATE water_stations SET name = ?, low_soil_humidity = ?, high_soil_humidity = ?, watering_time = ? WHERE uid = ?', [name, low_soil_humidity, high_soil_humidity, watering_time, uid])
      end
    end

    def self.register_water_station_checked(stationId, soil_humidity)
      query_db do |db|
        db.execute('UPDATE water_stations SET soil_humidity = ?, last_checked_at = ? WHERE uid = ?', [soil_humidity, Time.now.to_s, stationId])
      end
    end

    def self.register_water_station_watered(stationId)
      query_db do |db|
        db.execute('UPDATE water_stations SET last_watered_at = ? WHERE uid = ?', [Time.now.to_s, stationId])
      end
    end

    def self.update_environment_station(normal_humidity, high_temperature, max_temperature)
      query_db do |db|
        db.execute('UPDATE environment_station SET normal_humidity = ?, high_temperature = ?, max_temperature = ?', [normal_humidity, high_temperature, max_temperature])
      end
    end

    def self.register_environment_station_checked(temperature, humidity)
      query_db do |db|
        db.execute('UPDATE environment_station SET temperature = ?, humidity = ?, last_checked_at = ?', [temperature, humidity, Time.now.to_s])
      end
    end

    def self.log(event, message, station_id = nil)
      query_db do |db|
        db.execute("INSERT INTO log (created_at, event, message, station_id) VALUES (?, ?, ?, ?)", [Time.now.to_s, event, message, station_id ])
      end
    end

    def self.create
      query_db do |db|
        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS water_stations(
            uid             INTEGER PRIMARY KEY,
            name            VARCHAR(255),
            soil_humidity   INTEGER,
            last_checked_at TEXT,
            last_watered_at TEXT,

            low_soil_humidity  INTEGER,
            high_soil_humidity INTEGER,
            watering_time      INTEGER
          );
        SQL

        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS log(
            uid           INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at   TEXT         NOT NULL,
            event        VARCHAR(255) NOT NULL,
            message      VARCHAR(255) NOT NULL,
            station_id   INTEGER
          );
        SQL

        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS environment_station(
            temperature  REAL,
            humidity     REAL,
            last_checked_at TEXT,

            normal_humidity  INTEGER,
            high_temperature INTEGER,
            max_temperature  INTEGER
          );
        SQL
      end
    end

    def self.seed
      query_db do |db|
        [
          [0, "Station 0", 0, "", "", 30, 85, 1000],
          [1, "Station 1", 0, "", "", 30, 85, 1000]
        ].each do |row|
          db.execute("INSERT INTO water_stations (uid, name, soil_humidity, last_checked_at, last_watered_at, low_soil_humidity, high_soil_humidity, watering_time)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)", row)
        end


        db.execute("INSERT INTO environment_station (temperature, humidity, last_checked_at, normal_humidity, high_temperature, max_temperature)
                    VALUES (?, ?, ?, ?, ?, ?)", [0, 0, "", 40, 25, 30])

      end
    end

    def self.drop
      File.delete DATABASE_NAME if File.exists? DATABASE_NAME
    end
  end
end