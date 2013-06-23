require File.expand_path(File.join(File.dirname(__FILE__), '../../../test/test_helper'))

class MailerTest < MiniTest::Unit::TestCase
  describe HowSlow::Mailer do
    context '#metrics_email' do
      context 'email options defaults' do
        def setup
          @email_options = HowSlow::config[:email_options]
        end
          
        it ':to is nil' do
          assert_equal nil, @email_options[:to]
        end

        it ':from is nil' do
          assert_equal nil, @email_options[:from]
        end

        it ':subject is "metrics report"' do
          assert_equal "metrics report", @email_options[:subject]
        end

        context 'actions' do
          def setup
            @actions_options = HowSlow::config[:email_options][:actions]
          end

          it ':sort_by is ":total_runtime"' do
            assert_equal :total_runtime, @actions_options[:sort_by]
          end

          it ':show_measurements is [:total_runtime, :db_runtime, :view_runtime]' do
            assert_equal [:total_runtime, :db_runtime, :view_runtime], @actions_options[:show_measurements]
          end

          it ':number_of_actions is 50' do
            assert_equal 50, @actions_options[:number_of_actions]
          end

          it ':retention is 7.days' do
            assert_equal 7.days, @actions_options[:retention]
          end
        end

        context 'counters' do
          def setup
            @counters_options = HowSlow.config[:email_options][:counters]
          end

          it ':event_names is nil' do
            assert_equal nil, @counters_options[:event_names]
          end

          it ':sort_by is :alpha_asc' do
            assert_equal :alpha_asc, @counters_options[:sort_by]
          end

          it ':retention is 7.days' do
            assert_equal 7.days, @counters_options[:retention]
          end
        end
      end
    end
  end
end
