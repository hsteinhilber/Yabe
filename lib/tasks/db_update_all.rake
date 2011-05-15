# automatically runs migrations, updates the test db, and annotates the model
#
namespace :db do
  desc "Run migrations, prepare test database, and annotate model"
  task :update_all => 'db:migrate' do
    #Rake::Task['db:migrate'].invoke
    puts `annotate`
    Rake::Task['db:populate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
end

