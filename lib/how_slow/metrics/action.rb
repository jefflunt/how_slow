module HowSlow
  module Metrics
    # A metric to track the performance of controller actions.
    #
    class Action < HowSlow::Metrics::Base
      attr_accessor :status,
                    :total_runtime,
                    :db_runtime,
                    :view_runtime,
                    :other_runtime,
                    :params
      
      @status         # the HTTP status code returned from the action
      @total_runtime  # total time to run the action in milliseconds
      @db_runtime     # db time in milliseconds
      @view_runtime   # view time in milliseconds
      @params         # The params hash from the controller action

      def initialize(params_hash)
        super
        @type_name = 'action'
      end

      # The amount of time leftover when you subtract view_runtime and db_runtime
      # from total_runtime
      #
      def other_runtime
        @total_runtime - @db_runtime - @view_runtime
      end

      # The name of the controller action triggered
      #
      def action
        @params['action']
      end

      # The name of the controller triggered
      #
      def controller
        @params['controller']
      end

      # This 
      def as_json
        hash = super
        hash[:controller] = controller
        hash[:action] = action

        hash
      end
    end
  end
end
