require "rubygems"
require "bundler/setup"
require "sinatra"
require 'time_difference'
require File.join(File.dirname(__FILE__), "environment")

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :show_exceptions, :after_handler
end

configure :production, :development do
  enable :logging
end

def _log msg
  f = File.open("/tmp/sinatra.log", "a")
  f.puts msg
  f.close
end

def populate_cron_runs(action,cron_name)
  if action == 'start'
    CronRun.create(:cron_id => Cron.first(:name => cron_name).id,:start_time => DateTime.now, :alert => 0)
  elsif action == 'complete'
    cr = CronRun.last(:cron_id => Cron.first(:name => cron_name).id)
    cr.update(:end_time => DateTime.now)
  end
end

def alert cron_id, error_type, time, freq
  if error_type == 1
    _log "Cron #{Cron.first(:id => cron_id).name} started at #{time.strftime("%d-%m-%Y - %H:%M:%S")} but did not complete in #{freq} minutes"
  elsif error_type == 2
    _log "Cron #{Cron.first(:id => cron_id).name} did not start. It was supposed to run every #{freq} minutes. Last started at #{time.strftime("%d-%m-%Y - %H:%M:%S")}"
  end
end

Thread.new do
  while true do
    _log "#{Time.now} --- running thread"
    Cron.each do |cron|
      begin
        CronRun.all(:cron_id => cron.id).each do |cr|
          if ( cr.end_time == nil && cr.alert == 0 )
            cron_exec_time = Cron.first(:id => cr.cron_id).exec_time
            if TimeDifference.between(cr.start_time,DateTime.now).in_minutes.to_i > cron_exec_time
              cr.update(:alert => 1)
              alert(cr.cron_id, 1, cr.start_time, cron_exec_time)
            end
          end
        end
        alert(cron.id, 2, CronRun.last(:cron_id => cron.id).start_time, cron.ping_freq) if TimeDifference.between(CronRun.last(:cron_id => cron.id).start_time, DateTime.now).in_minutes.to_i > cron.ping_freq
      rescue Exception => e
        _log e.message
        _log e.backtrace
      ensure
        next
      end
    end
    sleep 60
  end
end

get "/" do
  @cron_hash = {}
  Cron.each do |cron|
    cr = CronRun.last(:cron_id => cron.id)
    @cron_hash[cron.name] = {:start_time => cr.start_time, :end_time => cr.end_time, :ping_freq => cron.ping_freq, :exec_freq => cron.exec_time}
  end
  erb :root
end

get "/cron" do
  @cron = Cron.first(:name => params[:name])
  cron_run = CronRun.all(:cron_id => @cron.id, :order => [ :id.desc ], :limit => 20)
  @cron_hash = { @cron.name => [] }
  cron_run.each do |cr|
    @cron_hash[@cron.name] << {:start_time => cr.start_time, :end_time => cr.end_time, :ping_freq => @cron.ping_freq, :exec_freq => @cron.exec_time}
  end
  erb :cron
end

post "/ping" do
  begin
    if Cron.first(:name => params[:name])
      populate_cron_runs params[:action], params[:name]
    else
      Cron.create(:name => params[:name], :exec_time => params[:et], :ping_freq => params[:pf])
      populate_cron_runs params[:action], params[:name]
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace
  end
end
