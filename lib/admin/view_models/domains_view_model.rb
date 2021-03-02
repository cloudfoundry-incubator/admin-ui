require 'date'
require_relative 'base_view_model'

module AdminUI
  class DomainsViewModel < AdminUI::BaseViewModel
    def do_items
      domains = @cc.domains

      # domains have to exist. Other record types are optional
      return result unless domains['connected']

      domain_annotations            = @cc.domain_annotations
      domain_labels                 = @cc.domain_labels
      organizations                 = @cc.organizations
      organizations_private_domains = @cc.organizations_private_domains
      routes                        = @cc.routes

      organizations_connected                 = organizations['connected']
      organizations_private_domains_connected = organizations_private_domains['connected']
      routes_connected                        = routes['connected']

      organization_hash = organizations['items'].map { |item| [item[:id], item] }.to_h

      domain_annotations_hash = {}
      domain_annotations['items'].each do |domain_annotation|
        return result unless @running

        Thread.pass

        domain_guid = domain_annotation[:resource_guid]
        domain_annotations_array = domain_annotations_hash[domain_guid]
        if domain_annotations_array.nil?
          domain_annotations_array = []
          domain_annotations_hash[domain_guid] = domain_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         domain_annotation,
            created_at_rfc3339: domain_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: domain_annotation[:updated_at].nil? ? nil : domain_annotation[:updated_at].to_datetime.rfc3339
          }

        domain_annotations_array.push(wrapper)
      end

      domain_labels_hash = {}
      domain_labels['items'].each do |domain_label|
        return result unless @running

        Thread.pass

        domain_guid = domain_label[:resource_guid]
        domain_labels_array = domain_labels_hash[domain_guid]
        if domain_labels_array.nil?
          domain_labels_array = []
          domain_labels_hash[domain_guid] = domain_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              domain_label,
            created_at_rfc3339: domain_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: domain_label[:updated_at].nil? ? nil : domain_label[:updated_at].to_datetime.rfc3339
          }

        domain_labels_array.push(wrapper)
      end

      domains_organizations_hash = {}
      if organizations_connected && organizations_private_domains_connected
        organizations_private_domains['items'].each do |organization_private_domain|
          return result unless @running

          Thread.pass

          domain_id = organization_private_domain[:private_domain_id]
          domain_organizations_array = domains_organizations_hash[domain_id]
          if domain_organizations_array.nil?
            domain_organizations_array = []
            domains_organizations_hash[domain_id] = domain_organizations_array
          end

          organization = organization_hash[organization_private_domain[:organization_id]]

          domain_organizations_array.push(organization) if organization
        end
      end

      domain_route_counters = {}
      routes['items'].each do |route|
        return result unless @running

        Thread.pass

        domain_id = route[:domain_id]
        domain_route_counters[domain_id] = 0 if domain_route_counters[domain_id].nil?
        domain_route_counters[domain_id] += 1
      end

      items = []
      hash  = {}

      domains['items'].each do |domain|
        return result unless @running

        Thread.pass

        guid                   = domain[:guid]
        domain_id              = domain[:id]
        owning_organization_id = domain[:owning_organization_id]
        shared                 = owning_organization_id.nil?
        organization           = shared ? nil : organization_hash[owning_organization_id]

        domain_annotation_array    = domain_annotations_hash[guid] || []
        domain_label_array         = domain_labels_hash[guid] || []
        domain_organizations_array = domains_organizations_hash[domain_id]
        domain_route_counter       = domain_route_counters[domain_id]

        row = []

        row.push("#{guid}/#{shared}")
        row.push(domain[:name])
        row.push(guid)
        row.push(domain[:created_at].to_datetime.rfc3339)

        if domain[:updated_at]
          row.push(domain[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(domain[:internal])
        row.push(shared)

        if organization
          row.push(organization[:name])
          # Only domains with owners can be privately shared
          if domain_organizations_array
            row.push(domain_organizations_array.length)
          elsif organizations_connected && organizations_private_domains_connected
            row.push(0)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil)
        end

        if domain_route_counter
          row.push(domain_route_counter)
        elsif routes_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'annotations'                  => domain_annotation_array,
            'domain'                       => domain,
            'labels'                       => domain_label_array,
            'owning_organization'          => organization,
            'private_shared_organizations' => domain_organizations_array
          }
      end

      result(true, items, hash, (1..9).to_a, (1..7).to_a)
    end
  end
end
