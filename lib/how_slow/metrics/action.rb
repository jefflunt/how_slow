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
        @params['action'] || @params[:action]
      end

      # The name of the controller triggered
      #
      def controller
        @params['controller'] || @params[:controller]
      end

      # Provides a string representation of this Action metric, in the format of:
      # [timestampe] :: [controller]/[action] [total_runtime] / [db_runtime] / [view_runtime]
      # e.g. 2013-05-02T18:24:51+00:00 :: /login/new    1409 / 272 / 1099
      def to_default_email_string
        "#{am.datetime} :: #{am.params['controller']}/#{am.params['action']}\t#{am.total_runtime.to_i} / #{am.db_runtime.to_i} / #{am.view_runtime.to_i}"
      end

      # This 
      def as_json
        hash = super
        hash['controller'] = controller
        hash['action'] = action

        hash
      end
    end
  end
end
