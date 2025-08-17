# frozen_string_literal: true

module Maglev
  class FetchSectionScreenshotPath
    include Injectable

    dependency :fetch_sections_path
    argument :theme, default: nil
    argument :section
    argument :absolute, default: false

    def call
      path = "#{fetch_sections_path.call(theme: theme)}/#{section.category}/#{section.id}.jpg"
      
      if absolute
        Rails.root.join("public/#{path}").to_s
      else
        # Check if we should use asset_host for the URL
        asset_host = Rails.application.config.asset_host || 
                    Rails.application.config.action_controller.asset_host
        
        if asset_host.present?
          # If asset_host is a proc, evaluate it
          if asset_host.is_a?(Proc)
            request_stub = OpenStruct.new(ssl?: Rails.env.production?, host: 'example.com')
            host = asset_host.call(path, request_stub)
          else
            host = asset_host
          end
          
          # Ensure host doesn't end with slash and build full URL
          "#{host.chomp('/')}/#{path}"
        else
          "/#{path}"
        end
      end
    end
  end
end
