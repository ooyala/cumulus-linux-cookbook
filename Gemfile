source 'https://rubygems.org'

gem 'test-kitchen', '~> 1.2.1', group: :integration
gem 'kitchen-vagrant', '= 0.15.0', group: :integration
gem 'librarian-chef'
gem 'berkshelf'
gem 'chef-zero'

group 'develop' do
  gem 'kitchen-docker-api'
  gem 'rake'
  gem 'foodcritic', git: 'https://github.com/mlafeldt/foodcritic.git', branch: 'improve-rake-task'
  gem 'rubocop'
  gem 'knife-cookbook-doc'
  gem 'chefspec', '>= 3.2.0'
end
