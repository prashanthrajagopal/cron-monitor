require "#{File.dirname(__FILE__)}/spec_helper"

describe 'cron' do
  before(:each) do
    @cron = Cron.new(:name => 'test', :exec_time => 5, :ping_freq => 10)
  end

  it 'is valid' do
    expect(@cron).to be_valid
  end

  it 'it requires a name, exec_time and ping_freq' do
    @cron = Cron.new
    expect(@cron).to_not be_valid
    expect(@cron.errors[:name]).to include("Name must not be blank")
    expect(@cron.errors[:exec_time]).to include("Exec time must not be blank")
    expect(@cron.errors[:ping_freq]).to include("Ping freq must not be blank")
  end
end
