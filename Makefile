install:
	bundle install

setup: install
	bundle exec rake db:setup
	bundle exec rake db:migrate
	bundle exec rake db:seed

test:
	bundle exec rspec

console:
	rails console