class Cron
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :required => true, :key => true
  property :exec_time,  Integer, :required => true
  property :ping_freq,  Integer, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name
  validates_presence_of :exec_time
  validates_presence_of :ping_freq
end
