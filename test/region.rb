# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

logger = InsightOps.new('185a71d5-32a7-4007-a12d-3295c75a10e2', 'eu')
logger.info('ssl')

describe InsightOps::Host::CONNECTION do
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
  InsightOps::Host::CONNECTION.new(token, region, local,
                                   debug, ssl,
                                   datahub_endpoint,
                                   host_id, custom_host,
                                   udp, endpoint)
  end

  let(:logger_console) { host.instance_variable_get(:@logger_console) }

  describe 'host' do
    it 'is an instance of CONNECTION' do
      assert_instance_of(InsightOps::Host::CONNECTION, host)
    end
    it 'region is expected value' do
      assert_equal(host.region, 'eu')
    end
    it 'local is expected value' do
      refute(host.local)
    end
    it 'debug is expected value' do
      refute(host.debug)
    end
    it 'ssl is expected value' do
      refute(host.ssl)
    end
    it 'udp port is expected value' do
      assert_nil(host.udp_port)
    end
    it 'id is expected value' do
      assert_equal(host_id, '')
    end
    it 'custom_host is expected value' do
      assert_equal(custom_host, [false, ''])
    end
  end
end
