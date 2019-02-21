require 'serialport'
require 'json'

module IoTGarden
  module Workers
    class SerialPortWorker

      def initialize(device, bauds)
        @serial_port  = SerialPort.new(device, bauds, 8, 1, SerialPort::NONE)
        @msg          = ''

        @serial_port.read_timeout = 1000
      end

      def run
        loop do
          if $api_queue.empty?
            read_from_serial_port
          else
            write_to_serial_port
          end
        end

        @serial_port.close
      end

      private

        def write_to_serial_port
          @serial_port.write $api_queue.pop.to_json
        end

        def read_from_serial_port
          i = @serial_port.gets '}'

          @msg += i unless i.nil?

          if @msg[-1] == '}'
            begin
              $db_queue.push(JSON.parse(@msg.chomp))
            rescue JSON::ParserError
              puts "JSON ERROR FOUND"
            end

            @msg.clear
          end
        end
    end
  end
end