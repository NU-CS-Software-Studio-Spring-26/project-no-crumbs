desc "Run linting, security scans, and tests"
task ci: [ "db:test:prepare" ] do
  sh "bin/rubocop"
  sh "bin/brakeman --no-pager -q"
  sh "bin/bundler-audit check --update"
  Rake::Task[:test].invoke
  puts "\nAll checks passed — you're good to push!"
end
