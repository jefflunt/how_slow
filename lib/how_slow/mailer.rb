require 'action_mailer'

class HowSlow::Mailer < ActionMailer::Base
  # This method expects an `options` hash in the following format:
  #
  # {
  #   :subject => "My title"                                  # optional - defaults to
  #                                                           # "<Rails.env.titleize> <app name> metrics"
  #   :actions => {
  #     :sort_by => :total_runtime,                           # which metric to use to sort the resulting list
  #                                                           # the default is :total_runtime
  #     :show_measurements => [:db_runtime, :view_runtime],   # one or more measurements to include
  #                                                           # the default includes all measurements
  #     :number_of_actions => 100,                            # number of action metrics to include
  #     :keep_since => 7.days.ago                             # how far back in time to include metrics
  #   },
  #   :counters => {
  #     :event_names => ['login', 'new signup'],  # the names of the counter events you want to include
  #     :keep_since => 7.days.ago                 # how far back in time to include metrics
  #     :sort => :alpha_asc                       # one of (:alpha_asc, :alpha_desc, :numeric_asc, :numeric_desc)
  #   }
  # }
  #
  # See lib/how_slow/setup.rb for default values
  def metrics_email(options)
    options = HowSlow::config[:email_options].merge(options)
    @subject = options[:subject]
    HashWithIndifferentAccess.new(options) unless options.class == HashWithIndifferentAccess

    reporter = HowSlow::Reporter.new

    @action_metrics = []
    if options[:actions]
      @action_sort_by = options[:actions][:sort_by]
      @measurements = options[:actions][:show_measurements]
      @number_of_actions = options[:actions][:number_of_actions]
      @action_keep_since = options[:actions][:retention].ago
      
      @action_metrics = slowest_actions_by(@action_sort_by, @number_of_actions, @action_keep_since)
    end
  
    @counter_metrics = []
    if options[:counters]
      event_names = options[:counters][:event_names]
      @counter_keep_since = options[:counters][:retention].ago

      @counter_sort_by = options[:counters]
      event_names.each{|e| counter_metrics << reporter.sum_counters_by(e, @counter_keep_since) }

      case @counter_sort_by
        when :alpha_asc     then counter_metrics.sort!{|a, b| a.event_name <=> b.event_name }
        when :alpha_desc    then counter_metrics.sort!{|a, b| b.event_name <=> a.event_name }
        when :numeric_asc   then counter_metrics.sort!{|a, b| a.count <=> b.count }
        when :numeric_desc  then counter_metrics.sort!{|a, b| b.count <=> a.count }
      end
    end

    mail(:to => options[:to], :from => options[:from], :subject => options[:subject])
  end
end
