require "rubygems"
require "bundler/setup"
require "sinatra"
require 'time_difference'
require 'pony'
require File.join(File.dirname(__FILE__), "environment")

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :show_exceptions, :after_handler
end

configure :production, :development do
  enable :logging
end

def _log msg
  f = File.open("logs/application.log", "a")
  f.puts msg
  f.close
end

def populate_cron_runs params
  if params[:status] == 'start'
    CronRun.create(:cron_id => Cron.first(:name => params[:name]).id,:start_time => DateTime.now, :alert => 0)
  elsif params[:status] == 'complete'
    cr = CronRun.last(:cron_id => Cron.first(:name => params[:name]).id)
    cr.update(:end_time => DateTime.now, :run_time => params[:et])
  end
end

def alert cron_id, error_type, time, freq
  msg = ""
  if error_type == 1
    msg = "Cron #{Cron.first(:id => cron_id).name} started at #{time.strftime("%d-%m-%Y - %H:%M:%S")} but did not complete in #{freq} minutes"
  elsif error_type == 2
    msg = "Cron #{Cron.first(:id => cron_id).name} did not start. It was supposed to run every #{freq} minutes. Last started at #{time.strftime("%d-%m-%Y - %H:%M:%S")}"
  end
  _log "sending mail with content ---------- #{msg}"
  _log Pony.mail(:to => ENV["EMAIL_TO"], :from => ENV["EMAIL_FROM"], :subject => 'CRON ALERT', :body => msg)
end

Thread.new do
  while true do
    _log "#{Time.now} --- running thread"
    Cron.each do |cron|
      begin
        CronRun.all(:cron_id => cron.id).each do |cr|
          if ( cr.end_time == nil && cr.alert == 0 )
            cron_exec_time = Cron.first(:id => cr.cron_id).exec_time
            if TimeDifference.between(cr.start_time, DateTime.now).in_minutes.to_i > cron_exec_time
              cr.update(:alert => 1)
              alert(cr.cron_id, 1, cr.start_time, cron_exec_time)
            end
          end
        end
        pf_diff = TimeDifference.between(CronRun.last(:cron_id => cron.id).start_time, DateTime.now).in_minutes.to_i
        if ( pf_diff  > cron.ping_freq )
          _log "MODULO ------- #{pf_diff % cron.ping_freq}"
          alert(cron.id, 2, CronRun.last(:cron_id => cron.id).start_time, cron.ping_freq) #if ( pf_diff  > cron.ping_freq && pf_diff % cron.ping_freq )
        end
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
    cron_failure = false
    if CronRun.last(:end_time => nil, :cron_id => cron.id)
      if TimeDifference.between(CronRun.last(:end_time => nil, :cron_id => cron.id).start_time, DateTime.now).in_hours < 24
        cron_failure = true
      else
        cron_failure = false
      end
    end
    @cron_hash[cron.name] = { :start_time => cr.start_time, :end_time => cr.end_time, :ping_freq => cron.ping_freq, :exec_freq => cron.exec_time, :cron_status => cron_failure }
  end
  erb :root
end

get "/cron" do
  @cron = Cron.first(:name => params[:name])
  cron_run = CronRun.all(:cron_id => @cron.id, :order => [ :id.desc ], :limit => 20)
  @cr_failed = nil
  if CronRun.last(:end_time => nil, :cron_id => @cron.id)
    if TimeDifference.between(CronRun.last(:end_time => nil, :cron_id => @cron.id).start_time, DateTime.now).in_hours < 24
      @cr_failed = CronRun.last(:end_time => nil, :cron_id => @cron.id)
    else
      @cr_failed = nil
    end
  end
  @cron_hash = { @cron.name => [] }
  cron_run.each do |cr|
    @cron_hash[@cron.name] << {:start_time => cr.start_time, :end_time => cr.end_time, :ping_freq => @cron.ping_freq, :exec_freq => @cron.exec_time, :run_time => cr.run_time}
  end
  erb :cron
end

post "/ping" do
  begin
    Cron.create(:name => params[:name], :exec_time => params[:et], :ping_freq => params[:pf]) if !Cron.first(:name => params[:name])
    populate_cron_runs params
  rescue Exception => e
    puts e.message
    puts e.backtrace
  end
end
