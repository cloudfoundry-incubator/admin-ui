
function ServiceKeysTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_KEYS, Constants.URL__SERVICE_KEYS_VIEW_MODEL);
}

ServiceKeysTab.prototype = new Tab();

ServiceKeysTab.prototype.constructor = ServiceKeysTab;

ServiceKeysTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceKeysLabelsTable = Table.createTable("ServiceKeysLabels", this.getServiceKeysLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceKeysLabelsActions(), Constants.FILENAME__SERVICE_KEY_LABELS, null, null);

    this.serviceKeysAnnotationsTable = Table.createTable("ServiceKeysAnnotations", this.getServiceKeysAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceKeysAnnotationsActions(), Constants.FILENAME__SERVICE_KEY_ANNOTATIONS, null, null);
    
    this.serviceKeysCredentialsTable = Table.createTable("ServiceKeysCredentials", this.getServiceKeysCredentialsColumns(), [[0, "asc"]], null, null, Constants.FILENAME__SERVICE_KEY_CREDENTIALS, null, null);
};

ServiceKeysTab.prototype.getColumns = function()
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

ServiceKeysTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service keys?",
                                                         "Delete",
                                                         "Deleting Service Keys",
                                                         Constants.URL__SERVICE_KEYS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceKeysTab.prototype.getServiceKeysLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceKeysLabels"),
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

                                          return this.formatCheckbox("ServiceKeysLabels", text, value);
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

ServiceKeysTab.prototype.getServiceKeysLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceKeysLabels",
                                                         "Are you sure you want to delete the service key's selected labels?",
                                                         "Delete",
                                                         "Deleting Service Key Label",
                                                         Constants.URL__SERVICE_KEYS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceKeysTab.prototype.getServiceKeysAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceKeysAnnotations"),
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

                                          return this.formatCheckbox("ServiceKeysAnnotations", text, value);
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

ServiceKeysTab.prototype.getServiceKeysAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceKeysAnnotations",
                                                         "Are you sure you want to delete the service key's selected annotations?",
                                                         "Delete",
                                                         "Deleting Service Key Annotation",
                                                         Constants.URL__SERVICE_KEYS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceKeysTab.prototype.getServiceKeysCredentialsColumns = function()
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

ServiceKeysTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ServiceKeysLabelsTableContainer").hide();
    $("#ServiceKeysAnnotationsTableContainer").hide();
    $("#ServiceKeysCredentialsTableContainer").hide();
};

ServiceKeysTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServiceKeysTab.prototype.showDetails = function(table, objects, row)
{
    var annotations         = objects.annotations;
    var credentials         = objects.credentials;
    var labels              = objects.labels;
    var organization        = objects.organization;
    var service             = objects.service;
    var serviceBroker       = objects.service_broker;
    var serviceInstance     = objects.service_instance;
    var serviceKey          = objects.service_key;
    var serviceKeyOperation = objects.service_key_operation;
    var servicePlan         = objects.service_plan;
    var space               = objects.space;

    this.addJSONDetailsLinkRow(table, "Service Key Name", Format.formatString(serviceKey.name), objects, true);
    this.addPropertyRow(table, "Service Key GUID", Format.formatString(serviceKey.guid));
    this.addPropertyRow(table, "Service Key Created", Format.formatDateString(serviceKey.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Key Updated", Format.formatDateString, serviceKey.updated_at);
    this.addFilterRowIfValue(table, "Service Key Events", Format.formatNumber, row[5], serviceKey.guid, AdminUI.showEvents);

    if (serviceKeyOperation != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Key Last Operation Type", Format.formatString, serviceKeyOperation.type);
        this.addRowIfValue(this.addPropertyRow, table, "Service Key Last Operation State", Format.formatString, serviceKeyOperation.state);

        this.addPropertyRow(table, "Service Key Last Operation Created", Format.formatDateString(serviceKeyOperation.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Key Last Operation Updated", Format.formatDateString, serviceKeyOperation.updated_at);

        if (serviceKeyOperation.broker_provided_operation != null && serviceKeyOperation.broker_provided_operation.length > 0)
        {
            this.addPropertyRow(table, "Service Key Last Operation Broker-Provided Operation", Format.formatString(serviceKeyOperation.broker_provided_operation));
        }

        if (serviceKeyOperation.description != null && serviceKeyOperation.description.length > 0)
        {
            this.addPropertyRow(table, "Service Key Last Operation Description", Format.formatString(serviceKeyOperation.description));
        }
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
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Active", Format.formatBoolean,servicePlan.active);
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
        $("#ServiceKeysLabelsTableContainer").show();

        this.serviceKeysLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#ServiceKeysAnnotationsTableContainer").show();

        this.serviceKeysAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
    
    if (credentials != null)
    {
        var credentialFound = false;

        var serviceKeysCredentialsTableData = [];

        for (var key in credentials)
        {
            credentialFound = true;

            var value = credentials[key];

            var serviceKeyCredentialRow = [];

            serviceKeyCredentialRow.push(key);
            serviceKeyCredentialRow.push(JSON.stringify(value));

            serviceKeysCredentialsTableData.push(serviceKeyCredentialRow);
        }

        if (credentialFound)
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ServiceKeysCredentialsTableContainer").show();

            this.serviceKeysCredentialsTable.api().clear().rows.add(serviceKeysCredentialsTableData).draw();
        }
    }
};
