# frozen_string_literal: true

module InsightOps
  # InsightOps Logging Host
  module Host
    def self.new(token, region, local, debug, ssl, datahub_endpoint, host_id,
                 custom_host, udp_port, use_data_endpoint)
      InsightOps::Host::CONNECTION.new(token, region, local, debug, ssl,
                                       datahub_endpoint, host_id, custom_host,
                                       udp_port, use_data_endpoint)
    end

    # Log formatter
    module InstanceMethods
      def formatter
        proc do |severity, datetime, _, msg|
          "#{datetime} #{format_message(msg, severity)}"
        end
      end

      def format_message(message_in, severity)
        message_in = message_in.inspect unless message_in.is_a?(String)

        "severity=#{severity}, #{message_in.lstrip}"
      end
    end
  end
end

require File.join(File.dirname(__FILE__), 'host', 'connection')
