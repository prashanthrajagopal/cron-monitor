class CronRun
  include DataMapper::Resource

  property :id,         Serial
  property :cron_id,    Integer, :required => true, :key => true
  property :start_time, DateTime, :required => false
  property :end_time,   DateTime, :required => false
  property :alert,      Integer, :required => false
  property :run_time,   Float
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :cron_id
end
