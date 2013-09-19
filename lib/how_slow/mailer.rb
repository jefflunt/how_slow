require 'action_mailer'

class HowSlow::Mailer < ActionMailer::Base
  # Any options passed into this method are merged with the default
  # options from `lib/how_slow/setup.rb`. 
  #
  # This method makes the following variables available to the view:
  #
  # @action_metrics - an array of HowSlow::Metrics::Action instances
  # @action_sort_by - the option being used to sort the action metrics
  # @action_retention - the maximum age of an Action metric that will show up in
  #                     @action_metrics - something like 7.days.ago
  # @counter_metrics - NOT an array of HowSlow::Metrics::Counter (I should
  #                    probably rename it), but instead an Array of Arrays
  #                    containing the counter name and its value. E.g.:
  #
  #                    [['logins', 123],
  #                     ['items_purchased', 15],
  #                     ['views', 1092]]
  # @counter_sort_by - the option being used to sort the counter metrics
  # @counter_retention - the maximum age of a Counter metric that will show up
  #                      @counter_metrics - something like 7.days.ago
  #
  # See app/views/how_slow/mailer/metrics_email.txt.erb for an example of how
  #     these are being used.
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
    @action_retention = options[:email_actions_retention].ago
    
    @action_metrics = reporter.slowest_actions_by(@action_sort_by, { :number_of_actions => number_of_actions, :retention => @action_retention})
  
    @counter_metrics = []

    event_names = options[:email_counters_events] || reporter.all_counter_event_names
    @counter_retention = options[:email_counters_retention].ago

    @counter_sort_by = options[:email_counters_sort]
    event_names.each{|e| @counter_metrics << [e, reporter.sum_counters_by(e, @counter_retention)] }

    case @counter_sort_by
      when :alpha_asc     then @counter_metrics.sort!{|a, b| a[0] <=> b[0] }
      when :alpha_desc    then @counter_metrics.sort!{|a, b| b[0] <=> a[0] }
      when :numeric_asc   then @counter_metrics.sort!{|a, b| a[1] <=> b[1] }
      when :numeric_desc  then @counter_metrics.sort!{|a, b| b[1] <=> a[1] }
    end

    mail(:from => sender, :to => recipients, :subject => subject)
  end
end
