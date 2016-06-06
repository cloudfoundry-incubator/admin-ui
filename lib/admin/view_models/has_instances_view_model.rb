require 'thread'
require_relative 'base_view_model'

module AdminUI
  class HasInstancesViewModel < AdminUI::BaseViewModel
    def add_instance_metrics(counters_hash, application, containers_hash, deas_instance_hash)
      if application[:state] == 'STARTED'
        counters_hash['reserved_memory'] += application[:memory] * application[:instances]
        counters_hash['reserved_disk'] += application[:disk_quota] * application[:instances]
      end

      application_guid = application[:guid]

      containers = containers_hash[application_guid]
      if containers
        containers.each do |container|
          Thread.pass

          counters_hash['used_memory'] += container[:memory_bytes]
          counters_hash['used_disk'] += container[:disk_bytes]
          counters_hash['used_cpu'] += container[:cpu_percentage]
        end
      end

      dea_instances = deas_instance_hash[application_guid]
      return if dea_instances.nil?
      dea_instances.each do |dea_instance|
        Thread.pass

        counters_hash['used_memory'] += dea_instance['used_memory_in_bytes'] unless dea_instance['used_memory_in_bytes'].nil?
        counters_hash['used_disk'] += dea_instance['used_disk_in_bytes'] unless dea_instance['used_disk_in_bytes'].nil?
        counters_hash['used_cpu'] += dea_instance['computed_pcpu'] * 100 unless dea_instance['computed_pcpu'].nil?
      end
    end

    def create_instance_hashes(containers, deas)
      containers_hash = {}
      containers['items'].each_value do |container|
        Thread.pass

        application_id = container[:application_id]

        container_array = containers_hash[application_id]
        if container_array.nil?
          container_array = []
          containers_hash[application_id] = container_array
        end
        container_array.push(container)
      end

      deas_instance_hash = {}
      deas['items'].each do |dea|
        next unless dea['connected']
        next unless dea['data']['instance_registry']
        dea['data']['instance_registry'].each_value do |application|
          application.each_value do |instance|
            Thread.pass

            application_id = instance['application_id']
            instance_array = deas_instance_hash[application_id]
            if instance_array.nil?
              instance_array = []
              deas_instance_hash[application_id] = instance_array
            end
            instance_array.push(instance)
          end
        end
      end

      [containers_hash, deas_instance_hash]
    end
  end
end
