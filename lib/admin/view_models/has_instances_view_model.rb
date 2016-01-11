require 'thread'
require_relative 'base_view_model'

module AdminUI
  class HasInstancesViewModel < AdminUI::BaseViewModel
    def add_instance_metrics(counters_hash, application, instance_hash)
      if application[:state] == 'STARTED'
        counters_hash['reserved_memory'] += application[:memory] * application[:instances]
        counters_hash['reserved_disk'] += application[:disk_quota] * application[:instances]
      end

      instances = instance_hash[application[:guid]]

      return if instances.nil?

      instances.each do |instance|
        Thread.pass

        counters_hash['used_memory'] += instance['used_memory_in_bytes'] unless instance['used_memory_in_bytes'].nil?
        counters_hash['used_disk'] += instance['used_disk_in_bytes'] unless instance['used_disk_in_bytes'].nil?
        counters_hash['used_cpu'] += instance['computed_pcpu'] unless instance['computed_pcpu'].nil?
      end
    end

    def create_instance_hash(deas)
      result = {}

      deas['items'].each do |dea|
        next unless dea['connected']
        next unless dea['data']['instance_registry']
        dea['data']['instance_registry'].each_value do |application|
          application.each_value do |instance|
            Thread.pass

            application_id = instance['application_id']
            result[application_id] = [] if result[application_id].nil?
            result[application_id].push(instance)
          end
        end
      end

      result
    end
  end
end
