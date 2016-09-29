source 'https://rubygems.org'
gem 'sinatra'
gem 'json', '>= 1.8.3'
gem 'dotenv'
gem 'rake'
gem 'data_mapper'
gem 'dm-core'
gem 'dm-mysql-adapter'
gem 'dm-timestamps'
gem 'dm-validations'
gem 'dm-aggregates'
gem 'dm-migrations'
gem 'time_difference'
gem 'pony'

group :production do
  gem 'unicorn'
end

group :test, :development do
  gem 'foreman'
  gem 'rspec', :require => 'spec'
  gem 'rack-test'
  gem 'dm-sqlite-adapter'
end
