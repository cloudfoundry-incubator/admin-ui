require_relative 'base_view_model'

module AdminUI
  class HasApplicationsViewModel < AdminUI::BaseViewModel
    def latest_app_guid_hash(items)
      latest = {}
      items.each do |item|
        key = item[:app_guid]
        old = latest[key]
        latest[key] = item if old.nil? || item[:id] > old[:id]
      end
      latest
    end

    def package_state(current_droplet, latest_droplet, latest_package)
      return 'PENDING' if latest_package.nil?
      return 'FAILED' if latest_package[:state] == 'FAILED'
      return 'PENDING' if latest_droplet.nil?
      return 'PENDING' if latest_package[:created_at] > latest_droplet[:created_at]
      return 'FAILED' if latest_droplet[:state] == 'FAILED'
      return 'PENDING' if current_droplet.nil?
      return 'PENDING' if latest_droplet[:id] != current_droplet[:id]
      return 'STAGED' if current_droplet[:state] == 'STAGED'

      'PENDING'
    end
  end
end
