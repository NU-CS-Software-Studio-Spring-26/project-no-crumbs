desc "Run tests and RuboCop"
task ci: [ :test ] do
  sh "bin/rubocop -a"
end
