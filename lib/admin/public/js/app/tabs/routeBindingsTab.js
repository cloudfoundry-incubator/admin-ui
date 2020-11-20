
function RouteBindingsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ROUTE_BINDINGS, Constants.URL__ROUTE_BINDINGS_VIEW_MODEL);
}

RouteBindingsTab.prototype = new Tab();

RouteBindingsTab.prototype.constructor = RouteBindingsTab;

RouteBindingsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.routeBindingsLabelsTable = Table.createTable("RouteBindingsLabels", this.getRouteBindingsLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getRouteBindingsLabelsActions(), Constants.FILENAME__ROUTE_BINDING_LABELS, null, null);

    this.routeBindingsAnnotationsTable = Table.createTable("RouteBindingsAnnotations", this.getRouteBindingsAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getRouteBindingsAnnotationsActions(), Constants.FILENAME__ROUTE_BINDING_ANNOTATIONS, null, null);
};

RouteBindingsTab.prototype.getColumns = function()
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
                   title:  "URI",
                   width:  "200px",
                   render: Format.formatURI
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

RouteBindingsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected route bindings?",
                                                         "Delete",
                                                         "Deleting Route Bindings",
                                                         Constants.URL__ROUTE_BINDINGS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

RouteBindingsTab.prototype.getRouteBindingsLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("RouteBindingsLabels"),
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

                                          return this.formatCheckbox("RouteBindingsLabels", text, value);
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

RouteBindingsTab.prototype.getRouteBindingsLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("RouteBindingsLabels",
                                                         "Are you sure you want to delete the route binding's selected labels?",
                                                         "Delete",
                                                         "Deleting Route Binding Label",
                                                         Constants.URL__ROUTE_BINDINGS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

RouteBindingsTab.prototype.getRouteBindingsAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("RouteBindingsAnnotations"),
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

                                          return this.formatCheckbox("RouteBindingsAnnotations", text, value);
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

RouteBindingsTab.prototype.getRouteBindingsAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("RouteBindingsAnnotations",
                                                         "Are you sure you want to delete the route binding's selected annotations?",
                                                         "Delete",
                                                         "Deleting Route Binding Annotation",
                                                         Constants.URL__ROUTE_BINDINGS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

RouteBindingsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#RouteBindingsLabelsTableContainer").hide();
    $("#RouteBindingsAnnotationsTableContainer").hide();
};

RouteBindingsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

RouteBindingsTab.prototype.showDetails = function(table, objects, row)
{
    var annotations           = objects.annotations;
    var domain                = objects.domain;
    var labels                = objects.labels;
    var organization          = objects.organization;
    var route                 = objects.route;
    var routeBinding          = objects.route_binding;
    var routeBindingOperation = objects.route_binding_operation;
    var service               = objects.service;
    var serviceBroker         = objects.service_broker;
    var serviceInstance       = objects.service_instance;
    var servicePlan           = objects.service_plan;
    var space                 = objects.space;

    this.addJSONDetailsLinkRow(table, "Route Binding GUID", Format.formatString(routeBinding.guid), objects, true);
    this.addPropertyRow(table, "Route Binding Created", Format.formatDateString(routeBinding.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Route Binding Updated", Format.formatDateString, routeBinding.updated_at);

    if (routeBindingOperation != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Route Binding Last Operation Type", Format.formatString, routeBindingOperation.type);
        this.addRowIfValue(this.addPropertyRow, table, "Route Binding Last Operation State", Format.formatString, routeBindingOperation.state);

        this.addPropertyRow(table, "Route Binding Last Operation Created", Format.formatDateString(routeBindingOperation.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Route Binding Last Operation Updated", Format.formatDateString, routeBindingOperation.updated_at);

        if (routeBindingOperation.broker_provided_operation != null && routeBindingOperation.broker_provided_operation.length > 0)
        {
            this.addPropertyRow(table, "Route Binding Last Operation Broker-Provided Operation", Format.formatString(routeBindingOperation.broker_provided_operation));
        }

        if (routeBindingOperation.description != null && routeBindingOperation.description.length > 0)
        {
            this.addPropertyRow(table, "Route Binding Last Operation Description", Format.formatString(routeBindingOperation.description));
        }
    }

    this.addRowIfValue(this.addPropertyRow, table, "Route Binding Service URL", Format.formatString, routeBinding.route_service_url);

    if (route != null)
    {
        if (row[8] != null)
        {
            if ((route.port != null) && (route.port !== 0))
            {
                this.addPropertyRow(table, "Route URI", Format.formatString(row[8]));
            }
            else
            {
                this.addURIRow(table, "Route URI", row[8]);
            }
        }

        this.addFilterRow(table, "Route GUID", Format.formatString(route.guid), route.guid, AdminUI.showRoutes);
    }

    if (domain != null)
    {
        this.addFilterRow(table, "Domain", Format.formatStringCleansed(domain.name), domain.guid, AdminUI.showDomains);
        this.addPropertyRow(table, "Domain GUID", Format.formatString(domain.guid));
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
        $("#RouteBindingsLabelsTableContainer").show();

        this.routeBindingsLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#RouteBindingsAnnotationsTableContainer").show();

        this.routeBindingsAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
