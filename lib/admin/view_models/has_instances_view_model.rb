require_relative 'base'

module AdminUI
  class HasInstancesViewModel < AdminUI::Base
    def initialize(logger, cc, varz)
      super(logger)

      @cc   = cc
      @varz = varz
    end

    def add_instance_metrics(counters_hash, application, instance_hash)
      counters_hash['reserved_memory'] += application['memory']     * application['instances']
      counters_hash['reserved_disk']   += application['disk_quota'] * application['instances']

      instances = instance_hash[application['guid']]

      unless instances.nil?
        # We keep a temporary hash of the instance indices encountered to determine actual instance count
        # Multiple crashed instances can have the same instance_index
        instance_index_hash = {}

        instances.each do |instance|
          instance_index_hash[instance['instance_index']] = nil

          counters_hash['used_memory'] += instance['used_memory_in_bytes'] unless instance['used_memory_in_bytes'].nil?
          counters_hash['used_disk']   += instance['used_disk_in_bytes']   unless instance['used_disk_in_bytes'].nil?
          counters_hash['used_cpu']    += instance['computed_pcpu']        unless instance['computed_pcpu'].nil?
        end

        counters_hash['instances']  += instance_index_hash.length
      end
    end

    def create_instance_hash(deas)
      result = {}

      deas['items'].each do |dea|
        next unless dea['connected']
        dea['data']['instance_registry'].each_value do |application|
          application.each_value do |instance|
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
