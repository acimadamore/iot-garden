require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cross_origin'

module IoTGarden
  class Api < Sinatra::Application
    set :bind, '0.0.0.0'

    configure do
      enable :cross_origin
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'


      if request.request_method == 'POST'
        body_parameters = request.body.read
        begin
          data= params.merge!(JSON.parse(body_parameters))
        rescue
        end
      end
    end

    get '/api' do
      json "IoT Garden API v1.0"
    end

    get '/api/water-stations' do
      json DB.all('water_stations')
    end

    get '/api/water-stations/:id' do
      json DB.find('water_stations', params['id'])
    end

    get '/api/water-stations/:id/water' do
      $api_queue.push({ type: "water-station", stationId: params['id']})

      json ({ event: "water-station", message: "Water station watered." })
    end

    # This should be PATCH/PUT but axios is not sending request as expected and i'm tired
    post '/api/water-stations/:id' do

      DB.update_water_station(params['id'], params['name'], params['minHumidity'], params['maxHumidity'], params['watering'])

      $api_queue.push({
        type:        "configure-water-station",
        stationId:   params['id'],
        name:        params['name'],
        minHumidity: params['minHumidity'],
        maxHumidity: params['maxHumidity'],
        watering:    params['watering']
      })

      json ({ event: "configure-water-station", message: "Water station configuration changed" })
    end

    get '/api/environment-station' do
      json DB.get_environment_station
    end

    # This should be PATCH/PUT but axios is not sending request as expected and i'm tired
    post '/api/environment-station' do
      DB.update_environment_station(normal_humidity, high_temperature, max_temperature)

      $api_queue.push({
        type:           "configure-environment",
        humidity:       params['normal_humidity'],
        temperature:    params['high_temperature'],
        maxTemperature: params['max_temperature']
      })

      json ({ event: "configure-environment", message: "Environment station configuration changed" })
    end

    get '/api/system/log' do
      json DB.all('log', 'DESC')
    end

    post '/api/system/turn-on' do
      $api_queue.push({ type: "turn-on"})

      json ({ event: "turn-on", message: "System turned On" })
    end

    post '/api/system/turn-off' do
      $api_queue.push({ type: "turn-off"})

      json ({ event: "turn-off", message: "System turned On" })
    end

    options "*" do
      response.headers["Allow"] = "GET, PUT, PATCH, POST, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
      response.headers["Access-Control-Allow-Origin"] = "*"
      200
    end
  end
end