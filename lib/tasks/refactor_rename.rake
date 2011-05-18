# automatically renames a model; 
# updates specs, tests, models, controllers, and views
# based on hiroshi's script-refactor plugin
# http://github.com/hiroshi/script-refactor

require 'find'
require 'rubygems'
require 'active_support'

namespace :refactor do
  desc "Renames a model"
  task :rename, [:old_name, :new_name] => :environment do |t, args|
    fail "Previous model name is required" if args[:old_name].blank?
    fail "New model name is required" if args[:new_name].blank?

    @old_name = args[:old_name]
    @new_name = args[:new_name]
    
    establish_rename_cmd
    replace_class_and_variable_names 
    rename_files_and_directories
    generate_migration
  end

  private
    def establish_rename_cmd
      case
      when File.directory?(".git")
        def rename_cmd(src, dst)
          "git mv \"#{src}\" \"#{dst}\""
        end
      when File.directory?(".svn")
        def rename_cmd(src, dst)
          "svn mv \"#{src}\" \"#{dst}\""
        end
      else
        def rename_cmd(src, dst)
          "mv \"#{src}\" \"#{dst}\""
        end
      end
    end

    def rename_files_and_directories
      "Renaming files and directories:"
      rename_paths.each do |src, dst|
        if File.exist? src
          puts cmd = rename_cmd(src, dst)
          `#{cmd}`
        end
      end
    end

    def replace_class_and_variable_names
      class_and_variables.each do |from, to|
        print "[#{from} ==> #{to}] "
      end
      print "\n"
      pattern = "(\\b|_)(#{class_and_variables.keys.join("|")})(\\b|[_A-Z])"
      puts "matching pattern: /#{pattern}/"

      Find.find('.') do |path|
        Find.prune if path =~ /((^\.\/(vendor|doc|log|script|public|db|tmp|autotest))|\.(git|svn))$/
        Find.prune if path =~ /(~|.swp)$/

        if File.file? path
          puts "processing file '#{path}'"
          content = File.read(path)
          content.split.each_with_index do |line, idx|
            puts "#{path}:#{idx+1} -- #{line.chomp}" if line =~ /#{pattern}/
          end

          replaced = content.gsub!(/#{pattern}/) { "#{$1}#{class_and_variables[$2]}#{$3}" }
          unless replaced.nil?
            File.open(path, "w") do |out|
              out.print content
            end
          end
        end
      end
    end

    def generate_migration
      puts 'generating table rename migration'
      migration_name = "Rename#{@old_name.classify}To#{@new_name.classify}"
      path = "./db/migrate/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{migration_name.underscore}.rb"

      File.open(path, "w") do |out|
        out.print <<END_MIGRATION
class #{migration_name} < ActiveRecord::Migration
  def self.up
    rename_table :#{@old_name.pluralize}, :#{@new_name.pluralize}
  end

  def self.down
    rename_table :#{@new_name.pluralize}, :#{@old_name.pluralize}
  end
end
END_MIGRATION
      end
    end

    def rename_paths
      { 
        "test/unit/#{@old_name}_test.rb" => "test/unit/#{@new_name}_test.rb",
        "test/functional/#{@old_name.pluralize}_controller_test.rb" => "test/functional/#{@new_name.pluralize}_controller_test.rb",
        "test/fixtures/#{@old_name.pluralize}.yml" => "test/fixtures/#{@new_name.pluralize}.yml",
        "spec/controllers/#{@old_name.pluralize}_controller_spec.rb" => "spec/controllers/#{@new_name.pluralize}_controller_spec.rb",
        "spec/helpers/#{@old_name.pluralize}_helper_spec.rb" => "spec/helpers/#{@new_name.pluralize}_helper_spec.rb",
        "spec/models/#{@old_name}_spec.rb" => "spec/models/#{@new_name}_spec.rb",
        "spec/requests/#{@old_name.pluralize}_spec.rb" => "spec/requests/#{@new_name.pluralize}_spec.rb",
        "spec/routing/#{@old_name.pluralize}_routing_spec.rb" => "spec/routing/#{@new_name.pluralize}_routing_spec.rb",
        "spec/views/#{@old_name.pluralize}" => "spec/views/#{@new_name.pluralize}",
        "app/views/#{@old_name.pluralize}" => "app/views/#{@new_name.pluralize}",
        "app/models/#{@old_name}.rb" => "app/models/#{@new_name}.rb",
        "app/helpers/#{@old_name.pluralize}_helper.rb" => "app/helpers/#{@new_name.pluralize}_helper.rb",
        "app/controllers/#{@old_name.pluralize}_controller.rb" => "app/controllers/#{@new_name.pluralize}_controller.rb"
      }
    end

    def class_and_variables
      {
        @old_name => @new_name,
        @old_name.classify => @new_name.classify,
        @old_name.pluralize => @new_name.pluralize,
        @old_name.classify.pluralize => @new_name.classify.pluralize
      }
    end
end
