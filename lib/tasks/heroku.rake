desc "Pushes application to heroku"
task :heroku do
  has_remote = `git remote`.include? 'heroku'
  fail 'heroku remote is not defined' unless has_remote

  heroku_installed = `heroku version`.include? 'heroku'
  fail 'heroku gem is not installed' unless heroku_installed

  if has_remote and heroku_installed
    puts `git push heroku master`
    puts `heroku rake db:migrate`
  end
end
