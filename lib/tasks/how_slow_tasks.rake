namespace :how_slow do
  desc 'Send an email containing application metrics'
  task :metrics_email => :environment do
    dd
    HowSlow::Mailer.metrics_email.deliver({:actions => {}, :counters => {}})
  end
end
