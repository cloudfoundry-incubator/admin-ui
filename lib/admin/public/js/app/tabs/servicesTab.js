
function ServicesTab(id) 
{
    Tab.call(this, id, Constants.FILENAME__SERVICES, Constants.URL__SERVICES_VIEW_MODEL);
}

ServicesTab.prototype = new Tab();

ServicesTab.prototype.constructor = ServicesTab;

ServicesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.servicesLabelsTable = Table.createTable("ServicesLabels", this.getServicesLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServicesLabelsActions(), Constants.FILENAME__SERVICE_LABELS, null, null);

    this.servicesAnnotationsTable = Table.createTable("ServicesAnnotations", this.getServicesAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServicesAnnotationsActions(), Constants.FILENAME__SERVICE_ANNOTATIONS, null, null);    
};

ServicesTab.prototype.getInitialSort = function() 
{
    return [[1, "asc"]];
};

ServicesTab.prototype.getColumns = function() 
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
                   title:  "Plan Updateable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Instances Retrievable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Bindings Retrievable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Allow Context Updates",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Shareable",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Provider Display Name",
                   width:  "100px",
                   render: Format.formatServiceString
               },
               {
                   title:  "Display Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:  "Requires",
                   width:  "200px",
                   render: Format.formatServiceStrings
               },
               {
                   title:     "Events",
                   width:     "70px",
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
               }
           ];
};

ServicesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected services?",
                                                         "Delete",
                                                         "Deleting Services",
                                                         Constants.URL__SERVICES,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Purge",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to purge the selected services?",
                                                         "Purge",
                                                         "Purging Services",
                                                         Constants.URL__SERVICES,
                                                         "?purge=true");
                                  },
                                  this)
               }
           ];
};

ServicesTab.prototype.getServicesLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServicesLabels"),
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

                                          return this.formatCheckbox("ServicesLabels", text, value);
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

ServicesTab.prototype.getServicesLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServicesLabels",
                                                         "Are you sure you want to delete the service's selected labels?",
                                                         "Delete",
                                                         "Deleting Service Label",
                                                         Constants.URL__SERVICES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServicesTab.prototype.getServicesAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServicesAnnotations"),
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

                                          return this.formatCheckbox("ServicesAnnotations", text, value);
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

ServicesTab.prototype.getServicesAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServicesAnnotations",
                                                         "Are you sure you want to delete the service's selected annotations?",
                                                         "Delete",
                                                         "Deleting Service Annotation",
                                                         Constants.URL__SERVICES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServicesTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ServicesLabelsTableContainer").hide();
    $("#ServicesAnnotationsTableContainer").hide();
};

ServicesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicesTab.prototype.showDetails = function(table, objects, row)
{
    var annotations   = objects.annotations;
    var labels        = objects.labels;
    var service       = objects.service;
    var serviceBroker = objects.service_broker;

    this.addJSONDetailsLinkRow(table, "Service Label", Format.formatString(service.label), objects, true);
    this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
    this.addRowIfValue(this.addPropertyRow, table, "Service Unique ID", Format.formatString, service.unique_id);
    this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Service Bindable", Format.formatBoolean, service.bindable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updateable", Format.formatBoolean, service.plan_updateable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Instances Retrievable", Format.formatBoolean, service.instances_retrievable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Bindings Retrievable", Format.formatBoolean, service.bindings_retrievable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Allow Context Updates", Format.formatBoolean, service.allow_context_updates);
    this.addRowIfValue(this.addPropertyRow, table, "Service Shareable", Format.formatBoolean, row[9]);
    this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    this.addPropertyRow(table, "Service Description", Format.formatString(service.description));

    if (row[15] != null)
    {
        for (var index = 0; index < row[15].length; index++)
        {
            var field = row[15][index];
            this.addPropertyRow(table, "Service Requires", Format.formatString(field));
        }
    }

    if (service.tags != null)
    {
        try
        {
            var serviceTags = jQuery.parseJSON(service.tags);
            
            if (serviceTags != null && serviceTags.length > 0)
            {
                for (var serviceTagIndex = 0; serviceTagIndex < serviceTags.length; serviceTagIndex++)
                {
                    var serviceTag = serviceTags[serviceTagIndex];
    
                    this.addPropertyRow(table, "Service Tag", Format.formatString(serviceTag));
                }
            }
        }
        catch (error)
        {
        }
    }
    
    if (service.extra != null)
    {
        try
        {
            var serviceExtra = jQuery.parseJSON(service.extra);
            
            this.addRowIfValue(this.addPropertyRow, table, "Service Display Name", Format.formatString, serviceExtra.displayName);
            this.addRowIfValue(this.addPropertyRow, table, "Service Provider Display Name", Format.formatString, serviceExtra.providerDisplayName);
            this.addRowIfValue(this.addFormattableTextRow, table, "Service Icon", Format.formatIconImage, serviceExtra.imageUrl, "service icon", "flot:left;");
            this.addRowIfValue(this.addPropertyRow, table, "Service Long Description", Format.formatString, serviceExtra.longDescription);
            
            if (serviceExtra.documentationUrl != null)
            {
                this.addURIRow(table, "Service Documentation URL", serviceExtra.documentationUrl);
            }
            
            if (serviceExtra.supportUrl != null)
            {
                this.addURIRow(table, "Service Support URL", serviceExtra.supportUrl);
            }
        }
        catch (error)
        {
        }
    }
    
    this.addFilterRowIfValue(table, "Service Events", Format.formatNumber, row[16], service.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Service Plans", Format.formatNumber, row[17], service.guid, AdminUI.showServicePlans);
    this.addRowIfValue(this.addPropertyRow, table, "Public Active Service Plans", Format.formatNumber, row[18]);
    this.addFilterRowIfValue(table, "Service Plan Visibilities", Format.formatNumber, row[19], service.guid, AdminUI.showServicePlanVisibilities);
    this.addFilterRowIfValue(table, "Service Instances", Format.formatNumber, row[20], service.guid, AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Service Instance Shares", Format.formatNumber, row[21], service.guid, AdminUI.showSharedServiceInstances);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[22], service.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Service Keys", Format.formatNumber, row[23], service.guid, AdminUI.showServiceKeys);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[24], service.guid, AdminUI.showRouteBindings);
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker Name", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
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
        $("#ServicesLabelsTableContainer").show();

        this.servicesLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#ServicesAnnotationsTableContainer").show();

        this.servicesAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
