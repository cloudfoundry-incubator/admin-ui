
function ServiceBindingsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_BINDINGS, Constants.URL__SERVICE_BINDINGS_VIEW_MODEL);
}

ServiceBindingsTab.prototype = new Tab();

ServiceBindingsTab.prototype.constructor = ServiceBindingsTab;

ServiceBindingsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceBindingsLabelsTable = Table.createTable("ServiceBindingsLabels", this.getServiceBindingsLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceBindingsLabelsActions(), Constants.FILENAME__SERVICE_BINDING_LABELS, null, null);

    this.serviceBindingsAnnotationsTable = Table.createTable("ServiceBindingsAnnotations", this.getServiceBindingsAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceBindingsAnnotationsActions(), Constants.FILENAME__SERVICE_BINDING_ANNOTATIONS, null, null);
    
    this.serviceBindingsCredentialsTable = Table.createTable("ServiceBindingsCredentials", this.getServiceBindingsCredentialsColumns(), [[0, "asc"]], null, null, Constants.FILENAME__SERVICE_BINDING_CREDENTIALS, null, null);

    this.serviceBindingsVolumeMountsTable = Table.createTable("ServiceBindingsVolumeMounts", this.getServiceBindingsVolumeMountsColumns(), [], null, null, Constants.FILENAME__SERVICE_BINDING_VOLUME_MOUNTS, null, null);
};

ServiceBindingsTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var name = item[1];
                                          if (name == null)
                                          {
                                              name = item[2];
                                          }

                                          return this.formatCheckbox(this.id, name, value);
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
                   width:  "150px",
                   render: Format.formatApplicationName
               },
               {
                   title:  "GUID",
                   width:  "200px",
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

ServiceBindingsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service bindings?",
                                                         "Delete",
                                                         "Deleting Service Bindings",
                                                         Constants.URL__SERVICE_BINDINGS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceBindingsTab.prototype.getServiceBindingsLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceBindingsLabels"),
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

                                          return this.formatCheckbox("ServiceBindingsLabels", text, value);
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

ServiceBindingsTab.prototype.getServiceBindingsLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceBindingsLabels",
                                                         "Are you sure you want to delete the service binding's selected labels?",
                                                         "Delete",
                                                         "Deleting Service Binding Label",
                                                         Constants.URL__SERVICE_BINDINGS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceBindingsTab.prototype.getServiceBindingsAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceBindingsAnnotations"),
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

                                          return this.formatCheckbox("ServiceBindingsAnnotations", text, value);
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

ServiceBindingsTab.prototype.getServiceBindingsAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceBindingsAnnotations",
                                                         "Are you sure you want to delete the service binding's selected annotations?",
                                                         "Delete",
                                                         "Deleting Service Binding Annotation",
                                                         Constants.URL__SERVICE_BINDINGS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceBindingsTab.prototype.getServiceBindingsCredentialsColumns = function()
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

ServiceBindingsTab.prototype.getServiceBindingsVolumeMountsColumns = function()
{
    return [
               {
                   title:  "Container Directory",
                   width:  "200px",
                   render: Format.formatVolumeMountString
               },
               {
                   title:  "Device Type",
                   width:  "200px",
                   render: Format.formatVolumeMountString
               },
               {
                   title:  "Mode",
                   width:  "200px",
                   render: Format.formatVolumeMountString
               }
           ];
};

ServiceBindingsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ServiceBindingsLabelsTableContainer").hide();
    $("#ServiceBindingsAnnotationsTableContainer").hide();
    $("#ServiceBindingsCredentialsTableContainer").hide();
    $("#ServiceBindingsVolumeMountsTableContainer").hide();
};

ServiceBindingsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServiceBindingsTab.prototype.showDetails = function(table, objects, row)
{
    var annotations             = objects.annotations;
    var application             = objects.application;
    var credentials             = objects.credentials;
    var labels                  = objects.labels;
    var organization            = objects.organization;
    var service                 = objects.service;
    var serviceBinding          = objects.service_binding;
    var serviceBindingOperation = objects.service_binding_operation;
    var serviceBroker           = objects.service_broker;
    var serviceInstance         = objects.service_instance;
    var servicePlan             = objects.service_plan;
    var space                   = objects.space;
    var volumeMounts            = objects.volume_mounts;

    this.addRowIfValue(this.addPropertyRow, table, "Service Binding Name", Format.formatString, serviceBinding.name, true);
    this.addJSONDetailsLinkRow(table, "Service Binding GUID", Format.formatString(serviceBinding.guid), objects, false);
    this.addPropertyRow(table, "Service Binding Created", Format.formatDateString(serviceBinding.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Binding Updated", Format.formatDateString, serviceBinding.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Service Binding Syslog Drain URL", Format.formatString, serviceBinding.syslog_drain_url);
    this.addFilterRowIfValue(table, "Service Binding Events", Format.formatNumber, row[6], serviceBinding.guid, AdminUI.showEvents);

    if (serviceBindingOperation != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Binding Last Operation Type", Format.formatString, serviceBindingOperation.type);
        this.addRowIfValue(this.addPropertyRow, table, "Service Binding Last Operation State", Format.formatString, serviceBindingOperation.state);

        this.addPropertyRow(table, "Service Binding Last Operation Created", Format.formatDateString(serviceBindingOperation.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Binding Last Operation Updated", Format.formatDateString, serviceBindingOperation.updated_at);

        if (serviceBindingOperation.broker_provided_operation != null && serviceBindingOperation.broker_provided_operation.length > 0)
        {
            this.addPropertyRow(table, "Service Binding Last Operation Broker-Provided Operation", Format.formatString(serviceBindingOperation.broker_provided_operation));
        }

        if (serviceBindingOperation.description != null && serviceBindingOperation.description.length > 0)
        {
            this.addPropertyRow(table, "Service Binding Last Operation Description", Format.formatString(serviceBindingOperation.description));
        }
    }

    if (application != null)
    {
        this.addFilterRow(table, "Application Name", Format.formatStringCleansed(application.name), application.guid, AdminUI.showApplications);
        this.addPropertyRow(table, "Application GUID", Format.formatString(application.guid));
    }

    if (serviceInstance != null)
    {
        this.addFilterRow(table, "Service Instance Name", Format.formatStringCleansed(serviceInstance.name), serviceInstance.guid, AdminUI.showServiceInstances);
        this.addPropertyRow(table, "Service Instance GUID", Format.formatString(serviceInstance.guid));
        this.addPropertyRow(table, "Service Instance Created", Format.formatDateString(serviceInstance.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Instance Updated", Format.formatDateString, serviceInstance.updated_at);
    }

    if (servicePlan != null)
    {
        this.addFilterRow(table, "Service Plan Name", Format.formatStringCleansed(servicePlan.name), servicePlan.guid, AdminUI.showServicePlans);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Unique ID", Format.formatString, servicePlan.unique_id);
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
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
        $("#ServiceBindingsLabelsTableContainer").show();

        this.serviceBindingsLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#ServiceBindingsAnnotationsTableContainer").show();

        this.serviceBindingsAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }

    if (credentials != null)
    {
        var credentialFound = false;

        var serviceBindingsCredentialsTableData = [];

        for (var key in credentials)
        {
            credentialFound = true;

            var value = credentials[key];

            var serviceBindingCredentialRow = [];

            serviceBindingCredentialRow.push(key);
            serviceBindingCredentialRow.push(JSON.stringify(value));

            serviceBindingsCredentialsTableData.push(serviceBindingCredentialRow);
        }

        if (credentialFound)
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ServiceBindingsCredentialsTableContainer").show();

            this.serviceBindingsCredentialsTable.api().clear().rows.add(serviceBindingsCredentialsTableData).draw();
        }
    }

    if ((volumeMounts != null) && (volumeMounts.length > 0))
    {
        var serviceBindingsVolumeMountsTableData = [];

        for (var index = 0; index < volumeMounts.length; index++)
        {
            var volumeMount = volumeMounts[index];

            var serviceBindingVolumeMountRow = [];

            serviceBindingVolumeMountRow.push(volumeMount.container_dir);
            serviceBindingVolumeMountRow.push(volumeMount.device_type);
            serviceBindingVolumeMountRow.push(volumeMount.mode);

            serviceBindingsVolumeMountsTableData.push(serviceBindingVolumeMountRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ServiceBindingsVolumeMountsTableContainer").show();

        this.serviceBindingsVolumeMountsTable.api().clear().rows.add(serviceBindingsVolumeMountsTableData).draw();
    }
};
