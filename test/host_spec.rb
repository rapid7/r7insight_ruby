# frozen_string_literal: true

require 'spec_helper'

describe Le::Host do
  let(:token)   { '11111111-2222-3333-aaaa-bbbbbbbbbbbb' }
  let(:local)   { false }
  let(:debug)   { false }
  let(:ssl)     { true }
  let(:udp)     { nil }

  let(:datahub_endpoint) { ['', 10_000] }
  let(:host_id) { '' }
  let(:custom_host) { [false, ''] }
  let(:data_endpoint) { true }

  let(:host) do
    Le::Host::CONNECTION.new(token, local, debug, ssl, datahub_endpoint, host_id, custom_host, udp, data_endpoint)
  end
  specify { _(host).must_be_instance_of Le::Host::CONNECTION }
end
