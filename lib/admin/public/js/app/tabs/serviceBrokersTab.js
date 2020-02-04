
function ServiceBrokersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_BROKERS, Constants.URL__SERVICE_BROKERS_VIEW_MODEL);
}

ServiceBrokersTab.prototype = new Tab();

ServiceBrokersTab.prototype.constructor = ServiceBrokersTab;

ServiceBrokersTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceBrokersLabelsTable = Table.createTable("ServiceBrokersLabels", this.getServiceBrokersLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceBrokersLabelsActions(), Constants.FILENAME__SERVICE_BROKER_LABELS, null, null);

    this.serviceBrokersAnnotationsTable = Table.createTable("ServiceBrokersAnnotations", this.getServiceBrokersAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServiceBrokersAnnotationsActions(), Constants.FILENAME__SERVICE_BROKER_ANNOTATIONS, null, null);
};

ServiceBrokersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

ServiceBrokersTab.prototype.getColumns = function()
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
                   title:  "State",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Service Dashboard Client",
                   width:  "300px",
                   render: Format.formatUserString
               },
               {
                   title:     "Services",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Plans",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Public Active Service Plans",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Plan Visibilities",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Instances",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Instance Shares",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Bindings",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Keys",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Route Bindings",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

ServiceBrokersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Service Broker",
                                                               "Managing Service Brokers",
                                                               Constants.URL__SERVICE_BROKERS);
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service brokers?",
                                                         "Delete",
                                                         "Deleting Service Brokers",
                                                         Constants.URL__SERVICE_BROKERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceBrokersTab.prototype.getServiceBrokersLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceBrokersLabels"),
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

                                          return this.formatCheckbox("ServiceBrokersLabels", text, value);
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

ServiceBrokersTab.prototype.getServiceBrokersLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceBrokersLabels",
                                                         "Are you sure you want to delete the service broker's selected labels?",
                                                         "Delete",
                                                         "Deleting Service Broker Label",
                                                         Constants.URL__SERVICE_BROKERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceBrokersTab.prototype.getServiceBrokersAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServiceBrokersAnnotations"),
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

                                          return this.formatCheckbox("ServiceBrokersAnnotations", text, value);
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

ServiceBrokersTab.prototype.getServiceBrokersAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServiceBrokersAnnotations",
                                                         "Are you sure you want to delete the service broker's selected annotations?",
                                                         "Delete",
                                                         "Deleting Service Broker Annotation",
                                                         Constants.URL__SERVICE_BROKERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServiceBrokersTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ServiceBrokersLabelsTableContainer").hide();
    $("#ServiceBrokersAnnotationsTableContainer").hide();
};

ServiceBrokersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServiceBrokersTab.prototype.showDetails = function(table, objects, row)
{
    var annotations   = objects.annotations;
    var labels        = objects.labels;
    var organization  = objects.organization;
    var serviceBroker = objects.service_broker;
    var space         = objects.space;

    this.addJSONDetailsLinkRow(table, "Service Broker Name", Format.formatString(serviceBroker.name), objects, true);
    this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
    this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker State", Format.formatString, serviceBroker.state);
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Auth Username", Format.formatString, serviceBroker.auth_username);
    this.addPropertyRow(table, "Service Broker Broker URL", Format.formatString(serviceBroker.broker_url));
    this.addFilterRowIfValue(table, "Service Broker Events", Format.formatNumber, row[6], serviceBroker.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Service Dashboard Client", Format.formatStringCleansed, row[7], row[7], AdminUI.showClients);
    this.addFilterRowIfValue(table, "Services", Format.formatNumber, row[8], serviceBroker.guid, AdminUI.showServices);
    this.addFilterRowIfValue(table, "Service Plans", Format.formatNumber, row[9], serviceBroker.guid, AdminUI.showServicePlans);
    this.addRowIfValue(this.addPropertyRow, table, "Public Active Service Plans", Format.formatNumber, row[10]);
    this.addFilterRowIfValue(table, "Service Plan Visibilities", Format.formatNumber, row[11], serviceBroker.guid, AdminUI.showServicePlanVisibilities);
    this.addFilterRowIfValue(table, "Service Instances", Format.formatNumber, row[12], serviceBroker.guid, AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Service Instance Shares", Format.formatNumber, row[13], serviceBroker.guid, AdminUI.showSharedServiceInstances);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[14], serviceBroker.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Service Keys", Format.formatNumber, row[15], serviceBroker.guid, AdminUI.showServiceKeys);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[16], serviceBroker.guid, AdminUI.showRouteBindings);

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
        $("#ServiceBrokersLabelsTableContainer").show();

        this.serviceBrokersLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#ServiceBrokersAnnotationsTableContainer").show();

        this.serviceBrokersAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
