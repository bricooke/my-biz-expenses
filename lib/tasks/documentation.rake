require 'rake/rdoctask'

namespace :doc do

def application_files
  %w(
    doc/README_FOR_APP
    app/**/*.rb
    lib/**/*.rb
  )
end

def framework_files
  %w(
    vendor/rails/railties/CHANGELOG
    vendor/rails/railties/MIT-LICENSE
    vendor/rails/activerecord/README
    vendor/rails/activerecord/CHANGELOG
    vendor/rails/activerecord/lib/active_record/**/*.rb
    vendor/rails/actionpack/README
    vendor/rails/actionpack/CHANGELOG
    vendor/rails/actionpack/lib/action_controller/**/*.rb
    vendor/rails/actionpack/lib/action_view/**/*.rb
    vendor/rails/actionmailer/README
    vendor/rails/actionmailer/CHANGELOG
    vendor/rails/actionmailer/lib/action_mailer/base.rb
    vendor/rails/actionwebservice/README
    vendor/rails/actionwebservice/CHANGELOG
    vendor/rails/actionwebservice/lib/action_web_service.rb
    vendor/rails/actionwebservice/lib/action_web_service/*.rb
    vendor/rails/actionwebservice/lib/action_web_service/api/*.rb
    vendor/rails/actionwebservice/lib/action_web_service/client/*.rb
    vendor/rails/actionwebservice/lib/action_web_service/container/*.rb
    vendor/rails/actionwebservice/lib/action_web_service/dispatcher/*.rb
    vendor/rails/actionwebservice/lib/action_web_service/protocol/*.rb
    vendor/rails/actionwebservice/lib/action_web_service/support/*.rb
    vendor/rails/activesupport/README
    vendor/rails/activesupport/CHANGELOG
    vendor/rails/activesupport/lib/active_support/**/*.rb
  )
end

def plugin_files
  FileList['vendor/plugins/*/lib/**/*.rb'] + FileList['vendor/plugins/*/README']
end

def all_files
  application_files + framework_files + plugin_files
end

desc "Build the comprehensive documentation, including the application, the framework and all plugins."
Rake::RDocTask.new(:all) do |r|
  # Configuration options
  r.rdoc_dir = 'doc/all'
  r.options << '--line-numbers' << '--inline-source'
  r.title    = "application_files + framework_files + plugin_files"
  r.template = "#{RAILS_ROOT}/doc/jamis.rb" if File.exist?("#{RAILS_ROOT}/doc/jamis.rb")

  all_files.each{ |f| r.rdoc_files.include(f) }
  r.rdoc_files.exclude('vendor/rails/activerecord/lib/active_record/vendor/*')
end

end