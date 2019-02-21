require_relative 'lib/iot_garden'

SERIAL_PORT_DEVICE = '/dev/ttyACM0'.freeze
SERIAL_PORT_BAUD   = 9600
RACK_PORT          = 4567

# FIX ME this is bad, very very bad
$api_queue = Queue.new
$db_queue  = Queue.new

t1 = Thread.new { IoTGarden::Workers::DBRegisterWorker.new.run }
t2 = Thread.new { IoTGarden::Workers::SerialPortWorker.new(SERIAL_PORT_DEVICE, SERIAL_PORT_BAUD).run }

Rack::Handler::WEBrick.run IoTGarden::Api, { Host: '0.0.0.0', Port: RACK_PORT }

