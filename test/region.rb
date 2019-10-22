# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

logger = Le.new('185a71d5-32a7-4007-a12d-3295c75a10e2', 'eu')
logger.info('ssl')

describe Le::Host::CONNECTION do
  let(:token)              { '11111111-2222-3333-aaaa-bbbbbbbbbbbb' }
  let(:region)             { 'eu' }
  let(:local)              { false }
  let(:debug)              { false }
  let(:ssl)                { false }
  let(:udp)                { nil }

  let(:datahub_endpoint)  { ['', 10_000] }
  let(:host_id)           { '' }
  let(:custom_host)       { [false, ''] }
  let(:endpoint)          { false }

  let(:host) do
  Le::Host::CONNECTION.new(token, region, local,
                           debug, ssl,
                           datahub_endpoint,
                           host_id, custom_host,
                           udp, endpoint)
  end

  let(:logger_console) { host.instance_variable_get(:@logger_console) }

  specify { host.must_be_instance_of Le::Host::CONNECTION }
  specify { host.region.must_equal 'eu' }
  specify { host.local.must_equal false }
  specify { host.debug.must_equal false }
  specify { host.ssl.must_equal false }
  specify { host.udp_port.must_equal nil }
  specify { host_id.must_equal '' }
  specify { custom_host.must_equal [false, ''] }
end
