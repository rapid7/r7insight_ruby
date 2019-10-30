Logging to Rapid7 Insight Platform in Ruby
=============================

[![Build Status](https://travis-ci.org/rapid7/r7insight_ruby.svg?branch=master)](https://travis-ci.org/rapid7/r7insight_ruby)
This is a library for logging from Ruby platforms to the Rapid7 Insight Platform, including Heroku.

It is available on github <https://github.com/rapid7/r7insight_ruby/> and rubygems
<http://rubygems.org/>.


Example
-------

    Rails.logger.info("information message")
    Rails.logger.warn("warning message")
    Rails.logger.debug("debug message")

Howto
-----

You must first register your account on the Rapid7 Insight Platform.

Once you have logged into the platform, create a new host with a name of your choice.
Inside this host, create a new logfile, selecting `Token TCP` (or `Plain TCP/UDP` if using UDP)
as the source type.

Heroku
------

To install the gem you must edit the Gemfile in your local heroku environment

Add the following line:

    gem 'r7insight'

Then from the cmd line run the following command:

    bundle install

This will install the gem on your local environment.

The next step is to configure the default rails logger to use the Rapid7 Insight Platform logger.  
Ensure you add a `require` to load in the package:

    require 'r7_insight.rb'

In your environment configuration file ( for production : `config/environments/production.rb`), add the following:

    Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION')

If you want to keep logging locally in addition to sending logs to in, just add local parameter after the key.
By default, this will write to the standard Rails log or to STDOUT if not using Rails:

    Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION', :local => true)

You may specify the local log device by providing a filename (String) or IO object (typically STDOUT, STDERR, or an open file):

    Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION', :local => 'log/my_custom_log.log')

If you want the gem to use SSL when streaming logs to the Rapid7 Insight Platform, add the ssl parameter and set it to true:

    Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION', :ssl => true)

If you want to print debug messages for the gem to a file called r7insightGem.log, add this:

	Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION', :debug => true)

If you want to use ActiveSupport::TaggedLogging logging, add this:

    Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION', :tag => true)

You can also specify the default level of the logger by adding a :

    Rails.logger = R7Insight.new('LOG_TOKEN', 'REGION', :log_level => Logger::<level>)

For the `LOG_TOKEN` argument, paste the token for the logfile you created earlier in the Rapid7 Insight UI or empty string for
a UDP connection.

For the `REGION` argument, provide the region of your account, e.g: 'eu', 'us' etc.

Additionally, when connecting via UDP, be sure to specify a port using the udp_port parameter:

    Rails.logger = R7Insight.new('', 'REGION' :udp_port => 13287)


Contact Support
------

Please email our support team at support@rapid7.com if you need any help.
