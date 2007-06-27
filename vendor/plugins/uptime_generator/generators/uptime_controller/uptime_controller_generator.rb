class UptimeControllerGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.file "uptime_controller.rb", File.join("app", "controllers", "uptime_controller.rb")
      m.file "uptime_helper.rb", File.join("app", "helpers", "uptime_helper.rb")
      m.route_uptime
    end
  end
  
end
