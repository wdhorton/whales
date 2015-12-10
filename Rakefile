PROJECTS = %w[whales_actions whales_orm]

desc 'Run all tests by default'
task default: :spec

desc "Run spec task for all projects"
task :spec do
  errors = []
  PROJECTS.each do |project|
    system(%(cd #{project} && #{$0} spec)) || errors << project
  end
  fail("Errors in #{errors.join(', ')}") unless errors.empty?
end

# begin
#   require 'rubygems'
#   require 'rspec/core/rake_task'


#   RSpec::Core::RakeTask.new(:spec) do |spec|
#     spec.pattern = '*/spec/*_spec.rb'
#   end

# rescue LoadError
#   task :spec do
#     abort "Rspec is not available. bundle install to run unit tests"
#   end
# end

# task default: :spec
