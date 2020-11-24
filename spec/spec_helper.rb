require "factory_bot_rails"
require "email_spec"
require "devise"
require "knapsack"

Dir["./spec/models/concerns/*.rb"].each { |f| require f }
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
Dir["./spec/shared/**/*.rb"].sort.each  { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include RequestSpecHelper, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include(CommonActions)
  config.include(ActiveSupport::Testing::TimeHelpers)

  config.before(:suite) do
    Rails.application.load_seed
  end

  config.before do |example|
    I18n.locale = :en
    Globalize.set_fallbacks_to_all_available_locales
    Setting["feature.user.skip_verification"] = nil
  end

  config.around(:each, :race_condition) do |example|
    self.use_transactional_tests = false
    example.run
    self.use_transactional_tests = true

    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
  end

  config.before(:each, type: :system) do
    Capybara::Webmock.start
  end

  config.after(:suite) do
    Capybara::Webmock.stop
  end

  config.after(:each, :page_driver) do
    page.driver.reset!
  end

  config.before(:each, type: :system) do |example|
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :headless_chrome
  end

  config.before(:each, type: :system) do
    Bullet.start_request
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(0)
  end

  config.after(:each, type: :system) do
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
  end

  config.before(:each, :delay_jobs) do
    Delayed::Worker.delay_jobs = true
  end

  config.after(:each, :delay_jobs) do
    Delayed::Worker.delay_jobs = false
  end

  config.before(:each, :remote_translations) do
    allow(RemoteTranslations::Microsoft::AvailableLocales)
      .to receive(:available_locales).and_return(I18n.available_locales.map(&:to_s))
  end

  config.before(:each, :with_frozen_time) do
    travel_to Time.current # TODO: use `freeze_time` after migrating to Rails 5.2.
  end

  config.after(:each, :with_frozen_time) do
    travel_back
  end

  config.before(:each, :application_zone_west_of_system_zone) do
    application_zone = ActiveSupport::TimeZone.new("Quito")
    system_zone = ActiveSupport::TimeZone.new("Madrid")

    allow(Time).to receive(:zone).and_return(application_zone)

    system_time_at_application_end_of_day = Date.current.end_of_day.in_time_zone(system_zone)

    allow(Time).to receive(:now).and_return(system_time_at_application_end_of_day)
    allow(Date).to receive(:today).and_return(system_time_at_application_end_of_day.to_date)
  end

  config.before(:each, :with_non_utc_time_zone) do
    application_zone = ActiveSupport::TimeZone.new("Madrid")

    allow(Time).to receive(:zone).and_return(application_zone)
  end

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

# Parallel build helper configuration for travis
Knapsack::Adapters::RSpecAdapter.bind
