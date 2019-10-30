# frozen_string_literal: true

require 'spec_helper'

describe R7Insight::Host do
  let(:token)   { '11111111-2222-3333-aaaa-bbbbbbbbbbbb' }
  let(:region)  { 'eu' }
  let(:local)   { false }
  let(:debug)   { false }
  let(:ssl)     { true }
  let(:udp)     { nil }

  let(:datahub_endpoint) { ['', 10_000] }
  let(:host_id) { '' }
  let(:custom_host) { [false, ''] }
  let(:use_data_endpoint) { true }

  let(:host) do
    R7Insight::Host::CONNECTION.new(token, region, local, debug, ssl, datahub_endpoint,
                                    host_id, custom_host, udp, use_data_endpoint)
  end
  describe 'host' do
    it 'is an instance of CONNECTION' do
      assert_instance_of(R7Insight::Host::CONNECTION, host)
    end
  end
end
