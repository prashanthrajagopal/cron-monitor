working_directory "/var/www/cron-monitor"

pid "/var/www/cron-monitor/pids/unicorn.pid"

stderr_path "/var/www/cron-monitor/logs/unicorn.log"
stdout_path "/var/www/cron-monitor/logs/unicorn.log"

listen "/tmp/unicorn.cron-monitor.sock"

worker_processes 2

timeout 30
