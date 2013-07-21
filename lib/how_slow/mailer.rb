require 'action_mailer'

class HowSlow::Mailer < ActionMailer::Base
  # Any options passed into this method are merged with the default
  # options from `lib/how_slow/setup.rb`. The key names in the options
  # hash must **exactly** match the key names in the gem's configuration
  # defaults in order to override the defaults.
  #
  # See lib/how_slow/setup.rb for default values
  def metrics_email(options={})
    options = HowSlow::config.merge(options)

    sender = options[:email_sender_address]
    recipients = options[:email_recipients]
    subject = options[:email_subject]
    HashWithIndifferentAccess.new(options) unless options.class == HashWithIndifferentAccess

    reporter = HowSlow::Reporter.new

    @action_metrics = []
    @action_sort_by = options[:email_actions_sort]
    number_of_actions = options[:email_actions_max]
    @action_keep_since = options[:email_actions_retention].ago
    
    @action_metrics = reporter.slowest_actions_by(@action_sort_by, number_of_actions, @action_keep_since)
  
    @counter_metrics = []

    event_names = options[:email_counters_events] || reporter.all_counter_event_names
    @counter_retention = options[:email_counters_retention].ago

    @counter_sort_by = options[:email_counters_sort]
    event_names.each{|e| @counter_metrics << [e, reporter.sum_counters_by(e, @counter_retention)] }

binding.pry
    case @counter_sort_by
      when :alpha_asc     then @counter_metrics.sort!{|a, b| a[0] <=> b[0] }
      when :alpha_desc    then @counter_metrics.sort!{|a, b| b[0] <=> a[0] }
      when :numeric_asc   then @counter_metrics.sort!{|a, b| a[1] <=> b[1] }
      when :numeric_desc  then @counter_metrics.sort!{|a, b| b[1] <=> a[1] }
    end

    mail(:from => sender, :to => recipients, :subject => subject)
  end
end
