
function ServiceInstancesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_INSTANCES, Constants.URL__SERVICE_INSTANCES_VIEW_MODEL);
}

ServiceInstancesTab.prototype = new Tab();

ServiceInstancesTab.prototype.constructor = ServiceInstancesTab;

ServiceInstancesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceInstancesLabelsTable = Table.createTable("ServiceInstancesLabels", this.getServiceInstancesLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceInstancesLabelsActions(), Constants.FILENAME__SERVICE_INSTANCE_LABELS, null, null);

    this.serviceInstancesAnnotationsTable = Table.createTable("ServiceInstancesAnnotations", this.getServiceInstancesAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceInstancesAnnotationsActions(), Constants.FILENAME__SERVICE_INSTANCE_ANNOTATIONS, null, null);
    
    this.serviceInstancesCredentialsTable = Table.createTable("ServiceInstancesCredentials", this.getServiceInstancesCredentialsColumns(), [[0, "asc"]], null, null, Constants.FILENAME__SERVICE_INSTANCE_CREDENTIALS, null, null);
};

ServiceInstancesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "User Provided",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Drain",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Shares",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Bindings",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Keys",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Route Bindings",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Type",
                   width:  "70px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "100px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Unique ID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Bindable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Free",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Public",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Label",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Unique ID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Bindable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

ServiceInstancesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Service Instance",
                                                               "Managing Service Instances",
                                                               Constants.URL__SERVICE_INSTANCES);
                                  }, 
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service instances?",
                                                         "Delete",
                                                         "Deleting Service Instances",
                                                         Constants.URL__SERVICE_INSTANCES,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Delete Recursive",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service instances and their associated shares, service bindings, service keys and route bindings?",
                                                         "Delete Recursive",
                                                         "Deleting Service Instances and Associated Service Bindings, Service Keys and Route Bindings",
                                                         Constants.URL__SERVICE_INSTANCES,
                                                         "?recursive=true");
                                  },
                                  this)
               },
               {
                   text:  "Purge",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to purge the selected service instances?",
                                                         "Purge",
                                                         "Purging Service Instances",
                                                         Constants.URL__SERVICE_INSTANCES,
                                                         "?recursive=true&purge=true");
                                  },
                                  this)
               }
           ];
};

ServiceInstancesTab.prototype.getServiceInstancesLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceInstancesLabels"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("ServiceInstancesLabels", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

ServiceInstancesTab.prototype.getServiceInstancesLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceInstancesLabels",
                                                         "Are you sure you want to delete the service instance's selected labels?",
                                                         "Delete",
                                                         "Deleting Service Instance Label",
                                                         Constants.URL__SERVICE_INSTANCES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceInstancesTab.prototype.getServiceInstancesAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceInstancesAnnotations"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("ServiceInstancesAnnotations", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

ServiceInstancesTab.prototype.getServiceInstancesAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceInstancesAnnotations",
                                                         "Are you sure you want to delete the service instance's selected annotations?",
                                                         "Delete",
                                                         "Deleting Service Instance Annotation",
                                                         Constants.URL__SERVICE_INSTANCES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceInstancesTab.prototype.getServiceInstancesCredentialsColumns = function()
{
    return [
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

ServiceInstancesTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ServiceInstancesLabelsTableContainer").hide();
    $("#ServiceInstancesAnnotationsTableContainer").hide();
    $("#ServiceInstancesCredentialsTableContainer").hide();
};

ServiceInstancesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

ServiceInstancesTab.prototype.showDetails = function(table, objects, row)
{
    var annotations              = objects.annotations;
    var credentials              = objects.credentials;
    var labels                   = objects.labels;
    var organization             = objects.organization;
    var service                  = objects.service;
    var serviceBroker            = objects.service_broker;
    var serviceInstance          = objects.service_instance;
    var serviceInstanceOperation = objects.service_instance_operation;
    var servicePlan              = objects.service_plan;
    var space                    = objects.space;

    this.addJSONDetailsLinkRow(table, "Service Instance Name", Format.formatString(serviceInstance.name), objects, true);
    this.addPropertyRow(table, "Service Instance GUID", Format.formatString(serviceInstance.guid));
    this.addPropertyRow(table, "Service Instance Created", Format.formatDateString(serviceInstance.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Instance Updated", Format.formatDateString, serviceInstance.updated_at);
    this.addPropertyRow(table, "Service Instance User Provided", Format.formatBoolean(!serviceInstance.is_gateway_service));
    this.addRowIfValue(this.addPropertyRow, table, "Service Instance Route Service URL", Format.formatString, serviceInstance.route_service_url);
    this.addRowIfValue(this.addPropertyRow, table, "Service Instance Syslog Drain URL", Format.formatString, serviceInstance.syslog_drain_url);
    
    if (serviceInstance.dashboard_url != null)
    {
        this.addURIRow(table, "Service Instance Dashboard URL", serviceInstance.dashboard_url);
    }

    if (serviceInstance.maintenance_info != null)
    {
        try
        {
            var serviceInstanceMaintenanceInfo = jQuery.parseJSON(serviceInstance.maintenance_info);

            this.addRowIfValue(this.addPropertyRow, table, "Service Instance Maintenance Info Version", Format.formatString, serviceInstanceMaintenanceInfo.version);
            this.addRowIfValue(this.addPropertyRow, table, "Service Instance Maintenance Info Description", Format.formatString, serviceInstanceMaintenanceInfo.description);
        }
        catch (error)
        {
        }
    }

    this.addFilterRowIfValue(table, "Service Instance Events", Format.formatNumber, row[7], serviceInstance.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Service Instance Shares", Format.formatNumber, row[8], serviceInstance.guid, AdminUI.showSharedServiceInstances);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[9], serviceInstance.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Service Keys", Format.formatNumber, row[10], serviceInstance.guid, AdminUI.showServiceKeys);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[11], serviceInstance.guid, AdminUI.showRouteBindings);
    
    if (serviceInstanceOperation != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Instance Last Operation Type", Format.formatString, serviceInstanceOperation.type);
        this.addRowIfValue(this.addPropertyRow, table, "Service Instance Last Operation State", Format.formatString, serviceInstanceOperation.state);

        this.addPropertyRow(table, "Service Instance Last Operation Created", Format.formatDateString(serviceInstanceOperation.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Instance Last Operation Updated", Format.formatDateString, serviceInstanceOperation.updated_at);

        if (serviceInstanceOperation.broker_provided_operation != null && serviceInstanceOperation.broker_provided_operation.length > 0)
        {
            this.addPropertyRow(table, "Service Instance Last Operation Broker-Provided Operation", Format.formatString(serviceInstanceOperation.broker_provided_operation));
        }

        if (serviceInstanceOperation.description != null && serviceInstanceOperation.description.length > 0)
        {
            this.addPropertyRow(table, "Service Instance Last Operation Description", Format.formatString(serviceInstanceOperation.description));
        }
    }
    
    if (serviceInstance.tags != null)
    {
        try
        {
            var serviceInstanceTags = jQuery.parseJSON(serviceInstance.tags);
            
            if (serviceInstanceTags != null && serviceInstanceTags.length > 0)
            {
                for (var serviceInstanceTagIndex = 0; serviceInstanceTagIndex < serviceInstanceTags.length; serviceInstanceTagIndex++)
                {
                    var serviceInstanceTag = serviceInstanceTags[serviceInstanceTagIndex];
    
                    this.addPropertyRow(table, "Service Instance Tag", Format.formatString(serviceInstanceTag));
                }
            }
        }
        catch (error)
        {
        }
    }

    if (servicePlan != null)
    {
        this.addFilterRow(table, "Service Plan Name", Format.formatStringCleansed(servicePlan.name), servicePlan.guid, AdminUI.showServicePlans);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Unique ID", Format.formatString, servicePlan.unique_id);
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Bindable", Format.formatBoolean, servicePlan.bindable);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Free", Format.formatBoolean, servicePlan.free);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Active", Format.formatBoolean, servicePlan.active);
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Public", Format.formatBoolean, servicePlan.public);
    }

    if (service != null)
    {
        this.addFilterRow(table, "Service Label", Format.formatStringCleansed(service.label), service.guid, AdminUI.showServices);
        this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Unique ID", Format.formatString, service.unique_id);
        this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
        this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
        this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    }
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
        this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }

    if ((labels != null) && (labels.length > 0))
    {
        var labelsTableData = [];

        for (var labelIndex = 0; labelIndex < labels.length; labelIndex++)
        {
            var wrapper = labels[labelIndex];
            var label   = wrapper.label;

            var path = label.resource_guid + "/metadata/labels/" + encodeURIComponent(label.key_name);
            if (label.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(label.key_prefix);
            }

            var labelRow = [];

            labelRow.push(path);
            labelRow.push(label.key_prefix);
            labelRow.push(label.key_name);
            labelRow.push(label.guid);
            labelRow.push(wrapper.created_at_rfc3339);
            labelRow.push(wrapper.updated_at_rfc3339);
            labelRow.push(label.value);

            labelsTableData.push(labelRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ServiceInstancesLabelsTableContainer").show();

        this.serviceInstancesLabelsTable.api().clear().rows.add(labelsTableData).draw();
    }

    if ((annotations != null) && (annotations.length > 0))
    {
        var annotationsTableData = [];

        for (var annotationIndex = 0; annotationIndex < annotations.length; annotationIndex++)
        {
            var wrapper    = annotations[annotationIndex];
            var annotation = wrapper.annotation;

            var path = annotation.resource_guid + "/metadata/annotations/" + encodeURIComponent(annotation.key);
            if (annotation.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(annotation.key_prefix);
            }

            var annotationRow = [];

            annotationRow.push(path);
            annotationRow.push(annotation.key_prefix);
            annotationRow.push(annotation.key);
            annotationRow.push(annotation.guid);
            annotationRow.push(wrapper.created_at_rfc3339);
            annotationRow.push(wrapper.updated_at_rfc3339);
            annotationRow.push(annotation.value);

            annotationsTableData.push(annotationRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ServiceInstancesAnnotationsTableContainer").show();

        this.serviceInstancesAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
    
    if (credentials != null)
    {
        var credentialFound = false;

        var serviceInstancesCredentialsTableData = [];

        for (var key in credentials)
        {
            credentialFound = true;

            var value = credentials[key];

            var serviceInstanceCredentialRow = [];

            serviceInstanceCredentialRow.push(key);
            serviceInstanceCredentialRow.push(JSON.stringify(value));

            serviceInstancesCredentialsTableData.push(serviceInstanceCredentialRow);
        }

        if (credentialFound)
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ServiceInstancesCredentialsTableContainer").show();

            this.serviceInstancesCredentialsTable.api().clear().rows.add(serviceInstancesCredentialsTableData).draw();
        }
    }
};
