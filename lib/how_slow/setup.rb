module HowSlow
  # Configuration defaults
  @config = {
    :event_subscriptions => [/process_action.action_controller/],
    :logger_filename => "metrics.log",
    :storage => :log_file,
    :email_options => {
      :to => nil,
      :from => nil,
      :subject => "metrics email",
      :actions => {
        :sort_by => :total_runtime,
        :show_measurements => [:total_runtime, :db_runtime, :view_runtime],
        :number_of_actions => 50,
        :retention => 7.days
      },
      :counters => {
        :event_names => nil,  # all event names
        :retention => 7.days,
        :sort_by => :alpha_asc
      }
    }
  }

  @valid_config_keys = @config.keys

  # Currently supported configuration options:
  #
  # :event_subscriptions - the list of patterns that will be captured be default
  # by the collector
  #
  # :logger_filename - the name of the file to which collected metrics will be
  # written. If this is set to "metrics.log" (the default), then the file will
  # be written to `#{Rails.root}/log/metrics.log`
  #
  def self.configure(opts = {})
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
