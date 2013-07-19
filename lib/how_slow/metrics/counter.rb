module HowSlow
  module Metrics
    # A metric for storing a count of something, such as every time a button is
    # pressed, so that you can count how many times a given features in your app
    # is being used.
    #
    # count - the count of this event
    #
    class Counter < HowSlow::Metrics::Base
      attr_accessor :count

      @count  # The total count for this metric

      def initialize(params_hash)
        super
        @type_name = 'counter'
      end

      # Provides a string representation of this Counter metric, in the format of:
      # [event_name] :: [count]A
      # e.g. new login :: 73
      #
      def to_default_email_string
        "#{am.event_name} :: #{am.count}"
      end
    end
  end
end
