require_relative 'has_applications_view_model'

module AdminUI
  class HasApplicationInstancesViewModel < AdminUI::HasApplicationsViewModel
    def add_instance_metrics(counters_hash, application, droplets_hash, latest_droplets_hash, latest_packages_hash, containers_hash)
      counters_hash['total'] += 1

      desired_state = application[:desired_state]
      unless desired_state.nil?
        counters_hash[desired_state] = 0 if counters_hash[desired_state].nil?
        counters_hash[desired_state] += 1
      end

      application_guid = application[:guid]

      current_droplet_guid = application[:droplet_guid]
      current_droplet      = current_droplet_guid.nil? ? nil : droplets_hash[current_droplet_guid]
      latest_droplet       = latest_droplets_hash[application_guid]
      latest_package       = latest_packages_hash[application_guid]
      package_state        = package_state(current_droplet, latest_droplet, latest_package)

      counters_hash[package_state] = 0 if counters_hash[package_state].nil?
      counters_hash[package_state] += 1

      containers = containers_hash[application_guid]
      containers&.each do |container|
        Thread.pass

        counters_hash['used_memory'] += container[:memory_bytes]
        counters_hash['used_disk'] += container[:disk_bytes]
        counters_hash['used_cpu'] += container[:cpu_percentage]
      end
    end

    def add_process_metrics(counters_hash, process)
      counters_hash['instances'] += process[:instances]
      state = process[:state]
      counters_hash[state] = 0 if counters_hash[state].nil?
      counters_hash[state] += 1
      return unless state == 'STARTED'
      return if process[:instances].nil?

      counters_hash['reserved_memory'] += process[:memory] * process[:instances] unless process[:memory].nil?
      counters_hash['reserved_disk'] += process[:disk_quota] * process[:instances] unless process[:disk_quota].nil?
    end

    def create_instance_hash(containers)
      containers_hash = {}
      containers['items'].each_value do |container|
        Thread.pass

        application_guid = container[:application_id]

        container_array = containers_hash[application_guid]
        if container_array.nil?
          container_array = []
          containers_hash[application_guid] = container_array
        end
        container_array.push(container)
      end

      containers_hash
    end
  end
end
