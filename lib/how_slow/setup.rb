module HowSlow
  # Configuration defaults
  @config = {
              :event_subscriptions => [/process_action.action_controller/],
              :logger_filename => "metrics.log"
            }
  @valid_config_keys = @config.keys
  @logger = nil

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.config
    @config
  end

  def self.full_path_to_log_file
    "#{Rails.root}/log/#{HowSlow.config[:logger_filename]}"
  end

end
