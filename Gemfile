source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{ repo_name }/#{ repo_name }" unless repo_name.include?('/')
  "https://github.com/#{ repo_name }.git"
end

# Specify your gem's dependencies in merit-heat.gemspec
gemspec

# Merit is here since it isn't currently published to RubyGems.org
gem 'quintel_merit', ref: 'master', github: 'quintel/merit'

# Development- and test-related non-essentials.
group(:extras) do
  gem 'pry'
end
