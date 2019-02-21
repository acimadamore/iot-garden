module IoTGarden
  module Workers
    class DBRegisterWorker

      def run
        loop do
          handle_queue unless $db_queue.empty?
        end
      end

      private

        def handle_queue
          data = $db_queue.pop

          case data["event"]
            when "water-station-checked"
              DB.register_water_station_checked data["stationId"], data["soilHumidity"]
            when "water-station-watered"
              DB.register_water_station_watered data["stationId"]
            when "environment-station-checked"
              DB.register_environment_station_checked data["temperature"], data["humidity"]
          end

          DB.log data["event"], data["message"], data["stationId"]
        end
    end
  end
end
