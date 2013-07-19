module HowSlow
  # Configuration defaults
  @config = {
    :event_subscriptions => [/process_action.action_controller/],
    :logger_filename => "metrics.log",
    :storage => :log_file,

    :email_sender_address => nil,
    :email_recipients => nil,
    :email_subject => "metrics report",
    :email_actions_sort => :total_runtime,
    :email_actions_max => 50,
    :email_actions_retention => 7.days,
    :email_counters_events => nil, #all events collected
    :email_counters_sort => :alpha_asc,
    :email_counters_retention => 7.days
  }

  @valid_config_keys = @config.keys

  def self.configure(opts={})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  # Returns a hash of the gem's configuration options.
  #
  def self.config
    @config
  end

  # The full path to the log file. If you just want the filename you can get
  # that from `HowSlow.config[:logger_filename]`
  def self.full_path_to_log_file
    "#{Rails.root}/log/#{HowSlow.config[:logger_filename]}"
  end

end
