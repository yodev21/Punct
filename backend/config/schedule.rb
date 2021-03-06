# ENV.each { |k, v| env(k, v) }
# require File.expand_path(File.dirname(__FILE__) + '/environment')
rails_env = ENV['RAILS_ENV'] || :development
set :environment, rails_env
# set :output, "#{Rails.root}/log/cron.log"
# set :output, "./log/cron.log"
# env :PATH, ENV['PATH']

# every '0 0 * * *' do # 毎日0時0分
#   command "echo 'learned_contents.till_next_review -1'"
#   runner 'lib/tasks/set_date.rb', :environment_variable => 'RAILS_ENV'
# end

# every '*/10 * * * *' do # 0分 10分 ..
#   command 'echo `date`'
#   runner 'lib/tasks/update_test_user.rb', :environment_variable => 'RAILS_ENV'
# end

every '0 4,15 * * *' do # 毎日4, 15時
  command 'echo [CRONTAB LOGGER] `date`'
  # runner 'puts "[CRONTAB LOGGER] #{Time.zone.now}"'
  runner 'lib/tasks/clean_test_users.rb'
end
