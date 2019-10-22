# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

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
  let(:endpoint) { false }

  let(:host) do
    Le::Host::CONNECTION.new(token, region, local, debug, ssl, datahub_endpoint,
                             host_id, custom_host, udp, endpoint)
  end

  let(:logger_console) { host.instance_variable_get(:@logger_console) }

  specify { _(host).must_be_instance_of Le::Host::CONNECTION }
  specify { _(host.region).must_equal 'eu' }
  specify { _(host.local).must_equal false }
  specify { _(host.debug).must_equal false }
  specify { _(host.ssl).must_equal false }
  specify { _(host.udp_port).nil? }
  specify { _(host_id).must_equal '' }
  specify { _(custom_host).must_equal [false, ''] }
end
