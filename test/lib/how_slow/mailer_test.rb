require File.expand_path(File.join(File.dirname(__FILE__), '../../../test/test_helper'))

class MailerTest < MiniTest::Unit::TestCase
  describe HowSlow::Mailer do
    context '#metrics_email' do
      context 'email options defaults' do
        def setup
          @config = HowSlow::config
        end
          
        it ':to is nil' do
          assert_equal nil, @config[:email_recipients]
        end

        it ':from is nil' do
          assert_equal nil, @config[:email_sender_address]
        end

        it ':subject is "metrics report"' do
          assert_equal "metrics report", @config[:email_subject]
        end

        context 'actions' do
          it ':sort_by is ":total_runtime"' do
            assert_equal :total_runtime, @config[:email_actions_sort]
          end

          # Disabled for now - see https://github.com/normalocity/how_slow/issues/19
          # it ':show_measurements is [:total_runtime, :db_runtime, :view_runtime]' do
          #   assert_equal [:total_runtime, :db_runtime, :view_runtime], @config[:email_k
          # end

          it ':number_of_actions is 50' do
            assert_equal 50, @config[:email_actions_max]
          end

          it ':retention is 7.days' do
            assert_equal 7.days, @config[:email_actions_retention]
          end
        end

        context 'counters' do
          it ':events is nil' do
            assert_equal nil, @config[:email_counters_events]
          end

          it ':sort_by is :alpha_asc' do
            assert_equal :alpha_asc, @config[:email_counters_sort]
          end

          it ':retention is 7.days' do
            assert_equal 7.days, @config[:email_counters_retention]
          end
        end
      end
    end
  end
end
