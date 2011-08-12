require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] ||= 'test'
  unless defined?(Rails)
    require File.dirname(__FILE__) + "/../config/environment"
  end
  require 'rspec/rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, comment the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    ### Part of a Spork hack. See http://bit.ly/arY19y
    # Emulate initializer set_clear_dependencies_hook in 
    # railties/lib/rails/application/bootstrap.rb
    ActiveSupport::Dependencies.clear

    def test_login(author)
      controller.login(author)
    end

    def integration_login(author)
      visit login_path
      fill_in :email, :with => author.email
      fill_in :password, :with => author.password
      click_button
    end

    RSpec::Matchers.define :include_hash do |expected|
      match do |actual|
        expected.stringify_keys!
        actual.find { |i| i.present? && i.stringify_keys.slice(*expected.keys) == expected }
      end

      failure_message_for_should do |actual|
        "expected #{actual} would contain a hash that is equal or a superset of #{expected}"
      end

      failure_message_for_should_not do |actual|
        "expected #{actual} would contain a hash that is not equal or a superset of #{expected}"
      end

      description do
        "contain a hash that is equal to or a superset of #{expected}"
      end
    end
  end
end

Spork.each_run do
end

