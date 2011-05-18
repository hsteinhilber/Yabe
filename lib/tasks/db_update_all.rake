# automatically runs migrations, updates the test db, and annotates the model
#
namespace :db do
  desc "Run migrations, prepare test database, and annotate model"
  task :update_all do
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
    Rake::Task['db:populate'].invoke
    puts `annotate`
  end
end

