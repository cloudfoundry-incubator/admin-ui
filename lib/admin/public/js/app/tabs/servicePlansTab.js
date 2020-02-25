
function ServicePlansTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SERVICE_PLANS, Constants.URL__SERVICE_PLANS_VIEW_MODEL);
}

ServicePlansTab.prototype = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.servicePlansLabelsTable = Table.createTable("ServicePlansLabels", this.getServicePlansLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServicePlansLabelsActions(), Constants.FILENAME__SERVICE_PLAN_LABELS, null, null);

    this.servicePlansAnnotationsTable = Table.createTable("ServicePlansAnnotations", this.getServicePlansAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getServicePlansAnnotationsActions(), Constants.FILENAME__SERVICE_PLAN_ANNOTATIONS, null, null);    
};

ServicePlansTab.prototype.getColumns = function()
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
                   title:  "Display Name",
                   width:  "200px",
                   render: Format.formatServiceString
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Visible Organizations",
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
               }
           ];
};

ServicePlansTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Public",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Service Plans",
                                                         Constants.URL__SERVICE_PLANS,
                                                         "",
                                                         '{"public":true}');
                                  },
                                  this)
               },
               {
                   text:  "Private",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Service Plans",
                                                         Constants.URL__SERVICE_PLANS,
                                                         "",
                                                         '{"public":false}');
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected service plans?",
                                                         "Delete",
                                                         "Deleting Service Plans",
                                                         Constants.URL__SERVICE_PLANS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServicePlansTab.prototype.getServicePlansLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServicePlansLabels"),
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

                                          return this.formatCheckbox("ServicePlansLabels", text, value);
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

ServicePlansTab.prototype.getServicePlansLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServicePlansLabels",
                                                         "Are you sure you want to delete the service plan's selected labels?",
                                                         "Delete",
                                                         "Deleting Service Plan Label",
                                                         Constants.URL__SERVICE_PLANS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServicePlansTab.prototype.getServicePlansAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("ServicePlansAnnotations"),
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

                                          return this.formatCheckbox("ServicePlansAnnotations", text, value);
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

ServicePlansTab.prototype.getServicePlansAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("ServicePlansAnnotations",
                                                         "Are you sure you want to delete the service plan's selected annotations?",
                                                         "Delete",
                                                         "Deleting Service Plan Annotation",
                                                         Constants.URL__SERVICE_PLANS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ServicePlansTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ServicePlansLabelsTableContainer").hide();
    $("#ServicePlansAnnotationsTableContainer").hide();
};

ServicePlansTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicePlansTab.prototype.showDetails = function(table, objects, row)
{
    var annotations   = objects.annotations;
    var labels        = objects.labels;
    var service       = objects.service;
    var serviceBroker = objects.service_broker;
    var servicePlan   = objects.service_plan;

    this.addJSONDetailsLinkRow(table, "Service Plan Name", Format.formatString(servicePlan.name), objects, true);
    this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Unique ID", Format.formatString, servicePlan.unique_id);
    this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Bindable", Format.formatBoolean, servicePlan.bindable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Plan Updateable", Format.formatBoolean, servicePlan.plan_updateable);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Free", Format.formatBoolean, servicePlan.free);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Active", Format.formatBoolean, servicePlan.active);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Public", Format.formatBoolean, servicePlan.public);
    this.addRowIfValue(this.addPropertyRow, table, "Service Plan Maximum Polling Duration", Format.formatNumber, servicePlan.maximum_polling_duration);
    this.addPropertyRow(table, "Service Plan Description", Format.formatString(servicePlan.description));

    if (servicePlan.extra != null)
    {
        try
        {
            var servicePlanExtra = jQuery.parseJSON(servicePlan.extra);

            this.addRowIfValue(this.addPropertyRow, table, "Service Plan Display Name", Format.formatString, servicePlanExtra.displayName);

            if (servicePlanExtra.bullets != null)
            {
                var bullets = servicePlanExtra.bullets;

                for (var bulletIndex = 0; bulletIndex < bullets.length; bulletIndex++)
                {
                    this.addPropertyRow(table, "Service Plan Bullet", Format.formatString(bullets[bulletIndex]));
                }
            }
        }
        catch (error)
        {
        }
    }

    if (servicePlan.maintenance_info != null)
    {
        try
        {
            var servicePlanMaintenanceInfo = jQuery.parseJSON(servicePlan.maintenance_info);

            this.addRowIfValue(this.addPropertyRow, table, "Service Plan Maintenance Info Version", Format.formatString, servicePlanMaintenanceInfo.version);
            this.addRowIfValue(this.addPropertyRow, table, "Service Plan Maintenance Info Description", Format.formatString, servicePlanMaintenanceInfo.description);
        }
        catch (error)
        {
        }
    }
    
    this.showSchema(table, servicePlan.create_instance_schema, "Service Plan Create Instance Schema");
    this.showSchema(table, servicePlan.update_instance_schema, "Service Plan Update Instance Schema");
    this.showSchema(table, servicePlan.create_binding_schema, "Service Plan Create Binding Schema");
    this.addFilterRowIfValue(table, "Service Plan Events", Format.formatNumber, row[12], servicePlan.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Service Plan Visibilities", Format.formatNumber, row[13], servicePlan.guid, AdminUI.showServicePlanVisibilities);
    this.addFilterRowIfValue(table, "Service Instances", Format.formatNumber, row[14], servicePlan.guid, AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Service Instance Shares", Format.formatNumber, row[15], servicePlan.guid, AdminUI.showSharedServiceInstances);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[16], servicePlan.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Service Keys", Format.formatNumber, row[17], servicePlan.guid, AdminUI.showServiceKeys);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[18], servicePlan.guid, AdminUI.showRouteBindings);

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
        $("#ServicePlansLabelsTableContainer").show();

        this.servicePlansLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#ServicePlansAnnotationsTableContainer").show();

        this.servicePlansAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};

ServicePlansTab.prototype.showSchema = function(table, schema, label)
{
    if (schema != null)
    {
        try
        {
            var json = jQuery.parseJSON(schema);
            this.addJSONDetailsLinkRow(table, label, Format.formatStringCleansed(schema), json, false);
        }
        catch (error)
        {
            this.addPropertyRow(table, label, Format.formatStringCleansed(schema));
        }
    }
};
