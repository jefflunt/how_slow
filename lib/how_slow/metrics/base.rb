module HowSlow
  module Metrics
    # The base metric.
    #
    class Base
      attr_accessor :datetime,
                    :type_name,
                    :event_name,
                    :meta

      @datetime     # When the metric was recorded
      @type_name    # The type of metric
      @event_name   # The name of the event, used to collect or combine events with the same name
      @meta         # A hash for any other information stored with this metric

      def initialize(params_hash)
        params_hash.each {|k,v| instance_variable_set("@#{k}", v) }
        @type_name = 'metric'
      end

      # Creates a hash representation suitable for JSON encoding. The resulting
      # hash contains every instance variable and its value.
      #
      def as_json
        hash = {}
        instance_variables.each{|var| hash[var.to_s.gsub(/@/, '')] = instance_variable_get var}
        hash
      end
    end
  end
end
