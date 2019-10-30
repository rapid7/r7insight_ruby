# frozen_string_literal: true

require 'spec_helper'

describe R7Insight do
  let(:token)              { '11111111-2222-3333-aaaa-bbbbbbbbbbbb' }
  let(:local)              { false }
  let(:region)             { 'eu' }
  let(:logger)             { R7Insight.new(token, region, local: local) }
  let(:logdev)             { logger.instance_variable_get(:@logdev).dev }
  let(:logger_console)     { logdev.instance_variable_get(:@logger_console) }
  let(:logger_console_dev) { logger_console.instance_variable_get(:@logdev).dev }

  describe 'when non-Rails environment' do
    describe 'is initialised with just a token' do
      let(:logger) { R7Insight.new(token, region) }

      describe 'logger' do
        it 'should be a Logger instance' do
          assert_instance_of(Logger, logger)
        end
      end

      describe 'logger device' do
        it 'is an instance of R7Insight::Host::CONNECTION' do
          assert_instance_of(R7Insight::Host::CONNECTION, logdev)
        end
        it 'local is false' do
          refute(logdev.local)
        end
        it 'ssl is true' do
          assert(logdev.ssl)
        end
      end

      describe 'logger console' do
        it 'is nil' do
          assert_nil(logger_console)
        end
      end
    end

    describe 'is initialized with :ssl => true' do
      let(:logger) { R7Insight.new(token, region, ssl: true) }

      describe 'logger device' do
        it 'ssl is true' do
          assert(logdev.ssl)
        end
      end
    end

    describe 'is initialized with :ssl => false' do
      let(:logger) { R7Insight.new(token, region, ssl: false) }

      describe 'logger device' do
        it 'ssl is false' do
          refute(logdev.ssl)
        end
      end
    end

    it 'logger device local is false' do
      refute(logdev.local)
    end

    it 'logger console is nil' do
      assert_nil(logger_console)
    end

    describe 'local is set to true' do
      let(:local) { true }

      it 'logger device local is true' do
        assert(logdev.local)
      end

      it 'logger console is instance of Logger' do
        assert_instance_of(Logger, logger_console)
      end

      it 'logger console device instance of IO' do
        assert_instance_of(IO, logger_console_dev)
      end
    end

    describe 'and :local => ' do
      let(:local_test_log) do
        Pathname.new(File.dirname(__FILE__))
                .join('fixtures', 'log', 'local_log.log')
      end
      let(:local) { log_file }

      describe 'Pathname' do
        let(:log_file) { local_test_log }

        describe 'logger device' do
          it 'is an instance of our CONNECTION' do
            assert_instance_of(R7Insight::Host::CONNECTION, logdev)
          end
          it 'local is true' do
            assert(logdev.local)
          end
        end

        describe 'logger console' do
          it 'is an instance of Logger' do
            assert_instance_of(Logger, logger_console)
          end
        end

        describe 'logger console device' do
          it 'is an instance of File' do
            assert_instance_of(File, logger_console_dev)
          end
          it 'path matches specified log file' do
            assert_match('local_log.log', logger_console_dev.path)
          end
        end
      end

      describe 'path string' do
        let(:log_file) { local_test_log.to_s }

        describe 'logger device' do
          it 'is an instance of CONNECTION' do
            assert_instance_of(R7Insight::Host::CONNECTION, logdev)
          end
          it 'local is true' do
            assert(logdev.local)
          end
        end

        describe 'logger console' do
          it 'is an instance of Logger' do
            assert_instance_of(Logger, logger_console)
          end
        end

        describe 'logger console device' do
          it 'is an instance of File' do
            assert_instance_of(File, logger_console_dev)
          end
          it 'path matches expected log filename' do
            assert_match('local_log.log', logger_console_dev.path)
          end
        end
      end

      describe 'File' do
        let(:log_file) { File.new(local_test_log, 'w') }

        describe 'logger device' do
          it 'is an instance of CONNECTION' do
            assert_instance_of(R7Insight::Host::CONNECTION, logdev)
          end
          it 'local is true' do
            assert(logdev.local)
          end
        end
        describe 'logger console' do
          it 'is an instance of Logger' do
            assert_instance_of(Logger, logger_console)
          end
        end
        describe 'logger console device' do
          it 'is an instance of File' do
            assert_instance_of(File, logger_console_dev)
          end
          it 'path matches expected log location' do
            assert_match('local_log.log', logger_console_dev.path)
          end
        end
      end
    end
  end

  describe 'when Rails environment' do
    before do
      class Rails
        def self.root
          Pathname.new(File.dirname(__FILE__)).join('fixtures')
        end

        def self.env
          'test'
        end
      end
    end
    after do
      Object.send(:remove_const, :Rails)
    end

    it 'ssl is true' do
      assert(logdev.ssl)
    end

    it 'local is false' do
      refute(logdev.local)
      assert_nil(logger_console)
    end

    describe 'and :local is true' do
      let(:local) { true }

      describe 'logger device' do
        it 'local is true' do
          assert(logdev.local)
        end
      end
      describe 'logger console' do
        it 'is an instance of Logger' do
          assert_instance_of(Logger, logger_console)
        end
      end
      describe 'logger console device' do
        it 'is an instance of File' do
          assert_instance_of(File, logger_console_dev)
        end
        it 'path matches expected log filename' do
          assert_match('test.log', logger_console_dev.path)
        end
      end
    end

    describe 'and :local => ' do
      let(:local_test_log) do
        Pathname.new(File.dirname(__FILE__))
                .join('fixtures', 'log', 'local_log.log')
      end
      let(:local) { log_file }

      describe 'Pathname' do
        let(:log_file) { local_test_log }

        describe 'logger device' do
          it 'is an instance of CONNECTION' do
            assert_instance_of(R7Insight::Host::CONNECTION, logdev)
          end
          it 'local is true' do
            assert(logdev.local)
          end
        end
        describe 'logger console' do
          it 'is an instance of Logger' do
            assert_instance_of(Logger, logger_console)
          end
        end
        describe 'logger console device' do
          it 'is an instance of File' do
            assert_instance_of(File, logger_console_dev)
          end
          it 'path matches expected log filename' do
            assert_match('local_log.log', logger_console_dev.path)
          end
        end
      end

      describe 'path string' do
        let(:log_file) { local_test_log.to_s }

        describe 'logger device' do
          it 'is an instance of CONNECTION' do
            assert_instance_of(R7Insight::Host::CONNECTION, logdev)
          end
          it 'local is true' do
            assert(logdev.local)
          end
        end
        describe 'logger console' do
          it 'is an instance of Logger' do
            assert_instance_of(Logger, logger_console)
          end
        end
        describe 'logger console device' do
          it 'is an instance of File' do
            assert_instance_of(File, logger_console_dev)
          end
          it 'path matches expected log filename' do
            assert_match('local_log.log', logger_console_dev.path)
          end
        end
      end

      describe 'File' do
        let(:log_file) { File.new(local_test_log, 'w') }

        describe 'logger device' do
          it 'is an instance of CONNECTION' do
            assert_instance_of(R7Insight::Host::CONNECTION, logdev)
          end
          it 'local is true' do
            assert(logdev.local)
          end
        end
        describe 'logger console' do
          it 'is an instance of Logger' do
            assert_instance_of(Logger, logger_console)
          end
        end
        describe 'logger console device' do
          it 'is an instance of File' do
            assert_instance_of(File, logger_console_dev)
          end
          it 'path matches expected log filename' do
            assert_match('local_log.log', logger_console_dev.path)
          end
        end
      end
    end
  end
end
