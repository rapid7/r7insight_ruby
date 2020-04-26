# frozen_string_literal: true

require 'socket'
require 'openssl'
require 'timeout'
require 'uri'

module R7Insight
  module Host
    # Class for connecting to the Rapid7 Insight Platform and handling the
    # connection
    class CONNECTION
      DATA_ENDPOINT = '.data.logs.insight.rapid7.com'
      DATA_PORT_UNSECURE = 80
      DATA_PORT_SECURE = 443
      API_SSL_PORT = 20_000
      SHUTDOWN_COMMAND = 'DIE!DIE!' # magic shutdown command string for worker
      SHUTDOWN_MAX_WAIT = 10 # max seconds to wait for queue shutdown clearing
      SHUTDOWN_WAIT_STEP = 0.2 # sleep duration (seconds) while shutting down
      CONNECTION_EXCEPTIONS = [
        Timeout::Error,
        Errno::EHOSTUNREACH,
        Errno::ECONNREFUSED,
        Errno::ECONNRESET,
        Errno::ETIMEDOUT,
        EOFError,
        Errno::EPIPE
      ].freeze

      include R7Insight::Host::InstanceMethods
      attr_accessor :token, :region, :queue, :started, :thread, :conn, :local,
                    :debug, :ssl, :datahub_enabled, :datahub_ip, :datahub_port,
                    :datahub_endpoint, :host_id, :host_name_enabled, :host_name,
                    :custom_host, :udp_port, :use_data_endpoint

      def initialize(token, region, local, debug, ssl, datahub_endpoint,
                     host_id, custom_host, udp_port, use_data_endpoint)
        if local
          device = if local.class <= TrueClass
                     if defined?(Rails)
                       Rails.root.join('log', "#{Rails.env}.log")
                     else
                       STDOUT
                     end
                   else
                     local
                   end
          @logger_console = Logger.new(device)
        end

        @region = region
        @local = local.nil? || local == false ? false : true # Replace "!!"
        @debug = debug
        @ssl = ssl
        @udp_port = udp_port
        @use_data_endpoint = use_data_endpoint

        @datahub_endpoint = datahub_endpoint
        if !@datahub_endpoint[0].empty?
          @datahub_enabled = true
          @datahub_ip = (@datahub_endpoint[0]).to_s
          @datahub_port = @datahub_endpoint[1]
        else
          @datahub_enabled = false
        end

        if @datahub_enabled && @ssl
          puts("\n\nYou Cannot have DataHub and SSL enabled at the same time.
 Please set SSL value to false in your environment.rb file or used Token-Based
 logging by leaving the Datahub IP address blank. Exiting application. \n\n")
          exit
        end

        # Check if region was specified
        puts("\n\nYou need to specify a region, such as 'eu'") if region.empty?

        # Check if DataHub is enabled
        # If datahub is not enabled, set the token to the token's parameter
        # If DH is enabled, make the token empty.
        if !datahub_enabled
          @token = token
        else
          @token = ''

          # !NOTE THIS @datahub_port conditional MAY NEED TO BE CHANGED IF SSL
          # CAN'T WORK WITH DH
          @datahub_port = @datahub_port.empty? ? API_SSL_PORT : datahub_port
          @datahub_ip = datahub_ip
        end

        @host_name_enabled = custom_host[0]
        @host_name = custom_host[1]

        if !host_id.empty?
          @host_id = host_id
          @host_id = "host_id=#{host_id}"
        else
          @host_id = ''
        end

        #  If no host name is given but required, assign the machine name
        if @host_name_enabled
          @host_name = Socket.gethostname if host_name.empty?

          @host_name = "host_name=#{@host_name}"
        end

        @queue = Queue.new
        @started = false
        @thread = nil

        init_debug if @debug
        at_exit { shutdown! }
      end

      def init_debug
        file_path = 'r7insightGem.log'
        file_path = 'log/r7insightGem.log' if File.exist?('log/')
        @debug_logger = Logger.new(file_path)
      end

      def dbg(message)
        @debug_logger.add(Logger::Severity::DEBUG, message) if @debug
      end

      def write(message)
        message = "#{message} #{host_id}" unless host_id.empty?
        message = "#{message} #{host_name}" if host_name_enabled

        @logger_console.add(Logger::Severity::UNKNOWN, message) if @local

        @queue << if message.scan(/\n/).empty?
                    "#{@token} #{message} \n"
                  else
                    "#{message.gsub(/^/, "#{@token} [#{random_message_id}]")}\n"
                  end

        if @started
          check_async_thread
        else
          start_async_thread
        end
      end

      def start_async_thread
        @thread = Thread.new { run }
        dbg 'R7Insight: Asynchronous socket writer started'
        @started = true
      end

      def check_async_thread
        @thread = Thread.new { run } unless @thread&.alive?
      end

      def close
        dbg 'R7Insight: Closing asynchronous socket writer'
        @started = false
      end

      def open_connection
        dbg 'R7Insight: Reopening connection to R7Insight API server'

        if @use_data_endpoint
          host = @region + DATA_ENDPOINT

          port = @ssl ? DATA_PORT_SECURE : DATA_PORT_UNSECURE
        elsif @udp_port
          host = @region + DATA_ENDPOINT
          port = @udp_port
        elsif @datahub_enabled
          host = @datahub_ip
          port = @datahub_port
        else
          host = @region + DATA_ENDPOINT
          port = @ssl ? DATA_PORT_SECURE : DATA_PORT_UNSECURE
        end

        if @udp_port
          @conn = UDPSocket.new
          @conn.connect(host, port)
        else
          socket = TCPSocket.new(host, port)

          if @ssl
            cert_store = OpenSSL::X509::Store.new
            cert_store.set_default_paths

            ssl_context = OpenSSL::SSL::SSLContext.new
            ssl_context.cert_store = cert_store

            if OpenSSL::SSL::SSLContext.method_defined? :min_version=
              ssl_context.min_version = OpenSSL::SSL::TLS1_1_VERSION
            end
            if OpenSSL::SSL::SSLContext.method_defined? :max_version=
              # For older versions of openssl (prior to 1.1.1) missing support for TLSv1.3
              ssl_context.max_version = if defined?(OpenSSL::SSL::TLS1_3_VERSION)
                                          OpenSSL::SSL::TLS1_3_VERSION
                                        else
                                          OpenSSL::SSL::TLS1_2_VERSION
                                        end
            end
            ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
            ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
            ssl_socket.hostname = host if ssl_socket.respond_to?(:hostname=)
            ssl_socket.sync_close = true
            Timeout.timeout(10) do
              ssl_socket.connect
            end
            @conn = ssl_socket
          else
            @conn = socket
          end
        end

        dbg 'R7Insight: Connection established'
      end

      def reopen_connection
        close_connection
        root_delay = 0.1
        loop do
          begin
            open_connection
            break
          rescue *CONNECTION_EXCEPTIONS
            dbg "R7Insight: Unable to connect to R7Insight due to timeout
(#{$ERROR_INFO})"
          rescue StandardError
            dbg "R7Insight: Got exception in reopenConnection - #{$ERROR_INFO}"
            raise
          end
          root_delay *= 2
          root_delay = 10 if root_delay >= 10
          wait_for = (root_delay + rand(root_delay)).to_i
          dbg "R7Insight: Waiting for #{wait_for}ms"
          sleep(wait_for)
        end
      end

      def close_connection
        begin
          if @conn.respond_to?(:sysclose)
            @conn.sysclose
          elsif @conn.respond_to?(:close)
            @conn.close
          end
        rescue StandardError
          dbg "R7Insight: couldn't close connection, close with exception -
 #{$ERROR_INFO}"
        ensure
          @conn = nil
        end
      end

      def run
        reopen_connection

        loop do
          data = @queue.pop
          break if data == SHUTDOWN_COMMAND

          loop do
            begin
              @conn.write(data)
            rescue *CONNECTION_EXCEPTIONS
              dbg "R7Insight: Connection timeout(#{$ERROR_INFO}), try to reopen
connection"
              reopen_connection
              next
            rescue StandardError
              dbg "R7Insight: Got exception in run loop - #{$ERROR_INFO}"
              raise
            end
            break
          end
        end

        dbg 'R7Insight: Closing Asynchronous socket writer'

        close_connection
      end

      private

      def random_message_id
        @random_message_id_sample_space ||= ('0'..'9').to_a.concat(('A'..'Z')
                                                                       .to_a)
        (0..5).map { @random_message_id_sample_space.sample }.join
      end

      # at_exit handler.
      # Attempts to clear the queue and terminate the async worker cleanly
      # before process ends.
      def shutdown!
        return unless @started

        dbg "R7Insight: commencing shutdown, queue has #{queue.size} entries to clear"
        queue << SHUTDOWN_COMMAND
        SHUTDOWN_MAX_WAIT.div(SHUTDOWN_WAIT_STEP).times do
          break if queue.empty?

          sleep SHUTDOWN_WAIT_STEP
        end
        dbg "R7Insight: shutdown complete, queue is #{queue.empty? ? '' : 'not '}
             empty with #{queue.size} entries"
      end
    end
  end
end
