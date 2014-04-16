
function ServiceInstancesTab(id)
{
    Tab.call(this, id);
}

ServiceInstancesTab.prototype = new Tab();

ServiceInstancesTab.prototype.constructor = ServiceInstancesTab;

ServiceInstancesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceInstancesApplicationsTable = Table.createTable("ServiceInstancesApplications", this.getApplicationColumns(), [[0, "asc"]], null, null);
}

ServiceInstancesTab.prototype.getInitialSort = function()
{
    return [[7, "asc"]];
}

ServiceInstancesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Provider",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Label",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Public",
                   "sWidth":  "70px"
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Bindings",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
               }
           ];
}

ServiceInstancesTab.prototype.getApplicationColumns = function()
{
    return [
               {
                   "sTitle":  "Application",
                   "sWidth":  "200px",
                   "mRender": function(name, type, item)
                              {
                                  var result = name;

                                  if (Format.doFormatting(type))
                                  {
                                      result += "<img onclick='ServiceInstancesTab.prototype.displayApplicationDetail(event, \"" + item[2] + "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                                  }

                                  return result;
                              }
               },
               {
                   "sTitle":  "Bound",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
           ];
}

ServiceInstancesTab.prototype.refresh = function(reload)
{
    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      reload);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     reload);
    var serviceBindingsDeferred  = Data.get(Constants.URL__SERVICE_BINDINGS,  reload);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, reload);
    var servicePlansDeferred     = Data.get(Constants.URL__SERVICE_PLANS,     reload);
    var servicesDeferred         = Data.get(Constants.URL__SERVICES,          reload);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            reload);

    $.when(applicationsDeferred, organizationsDeferred, serviceBindingsDeferred, serviceInstancesDeferred, servicePlansDeferred, servicesDeferred, spacesDeferred).done($.proxy(function(applicationsResult, organizationsResult, serviceBindingsResult, serviceInstancesResult, servicePlansResult, servicesResult, spacesResult)
    {
        this.updateData([applicationsResult, organizationsResult, serviceBindingsResult, serviceInstancesResult, servicePlansResult, servicesResult, spacesResult], reload);

        this.serviceInstancesApplicationsTable.fnDraw();
    },
    this));
}

ServiceInstancesTab.prototype.getTableData = function(results)
{
    var applications     = results[0].response.items; // TODO - use later to relate to apps in subtable and count in main table
    var organizations    = results[1].response.items;
    var serviceBindings  = results[2].response.items; // TODO - use later to relate to apps in subtable and count in main table
    var serviceInstances = results[3].response.items;
    var servicePlans     = results[4].response.items;
    var services         = results[5].response.items;
    var spaces           = results[6].response.items;

    var applicationMap = [];

    for (var applicationIndex in applications)
    {
        var application = applications[applicationIndex];

        applicationMap[application.guid] = application;
    }

    var organizationMap = [];

    for (var organizationIndex in organizations)
    {
        var organization = organizations[organizationIndex];

        organizationMap[organization.guid] = organization;
    }

    var serviceBindingAppsMap = [];

    for (var serviceBindingIndex in serviceBindings)
    {
        var serviceBinding = serviceBindings[serviceBindingIndex];

        var serviceInstanceGuid = serviceBinding.service_instance_guid;

        var arrayOfBindingsApps = serviceBindingAppsMap[serviceInstanceGuid];

        if (arrayOfBindingsApps == null)
        {
            arrayOfBindingsApps = [];
            serviceBindingAppsMap[serviceInstanceGuid] = arrayOfBindingsApps;
        }

        var application = applicationMap[serviceBinding.app_guid];

        if (application != null)
        {
            arrayOfBindingsApps.push({
                                         "application"    : application,
                                         "serviceBinding" : serviceBinding
                                     });
        }
    }

    var serviceMap = [];

    for (var serviceIndex in services)
    {
        var service = services[serviceIndex];

        serviceMap[service.guid] = service;
    }

    var servicePlanMap = [];

    for (var servicePlanIndex in servicePlans)
    {
        var servicePlan = servicePlans[servicePlanIndex];

        servicePlanMap[servicePlan.guid] = servicePlan;
    }

    var spaceMap = [];

    for (var spaceIndex in spaces)
    {
        var space = spaces[spaceIndex];

        spaceMap[space.guid] = space;
    }

    var tableData = [];

    for (var serviceInstanceIndex in serviceInstances)
    {
        var serviceInstance = serviceInstances[serviceInstanceIndex];

        var servicePlan  = servicePlanMap[serviceInstance.service_plan_guid];
        var service      = (servicePlan == null) ? null : serviceMap[servicePlan.service_guid];
        var space        = spaceMap[serviceInstance.space_guid];
        var organization = (space == null) ? null : organizationMap[space.organization_guid];

        var row = [];

        if (service != null)
        {
            row.push(service.provider);
            row.push(service.label);
            row.push(service.version);
            row.push(service.created_at);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 4);
        }

        if (servicePlan != null)
        {
            row.push(servicePlan.name);
            row.push(servicePlan.created_at);
            row.push(servicePlan.public);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 3);
        }

        row.push(serviceInstance.name);
        row.push(serviceInstance.created_at);

        var serviceBindingAppsArray = serviceBindingAppsMap[serviceInstance.guid];
 
        if (serviceBindingAppsArray != null)
        {
            row.push(serviceBindingAppsArray.length);
        }
        else
        {
            row.push(0);
        }

        if (organization != null && space != null)
        {
            row.push(organization.name + "/" + space.name);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push({
                     "bindingsAndApplications": serviceBindingAppsArray,
                     "organization"           : organization,
                     "service"                : service,
                     "serviceInstance"        : serviceInstance,
                     "servicePlan"            : servicePlan,
                     "space"                  : space
                 });

        tableData.push(row);
    }

    return tableData;
}

ServiceInstancesTab.prototype.clickHandler = function()
{
    var tableTools = TableTools.fnGetInstance("ServiceInstancesTable");

    var selected = tableTools.fnGetSelectedData();

    this.hideDetails();

    $("#ServiceInstancesApplicationsTableContainer").hide();

    if (selected.length > 0)
    {
        $("#ServiceInstancesDetailsLabel").show();

        var containerDiv = $("#ServiceInstancesPropertiesContainer").get(0);

        var table = this.createPropertyTable(containerDiv);

        var row = selected[0];

        var target = row[11];

        var bindingsAndApplications = target.bindingsAndApplications;
        var organization            = target.organization;
        var service                 = target.service;
        var serviceInstance         = target.serviceInstance;
        var servicePlan             = target.servicePlan;
        var space                   = target.space;

        this.addJSONDetailsLinkRow(table, "Service Instance Name", Format.formatString(serviceInstance.name), target, true);
        this.addPropertyRow(table, "Service Instance Created", Format.formatDateString(serviceInstance.created_at));

        if (serviceInstance.dashboard_url != null)
        {
            var dashboardLink = document.createElement("a");
            $(dashboardLink).attr("target", "_blank");
            $(dashboardLink).attr("href", serviceInstance.dashboard_url);
            $(dashboardLink).addClass("tableLink");
            $(dashboardLink).html(serviceInstance.dashboard_url);

            this.addRow(table, "Service Instance Dashboard URL", dashboardLink);
        }

        if (service != null)
        {
            if (service.provider != null)
            {
                this.addPropertyRow(table, "Service Provider", Format.formatString(service.provider));
            }

            this.addPropertyRow(table, "Service Label", Format.formatString(service.label));

            if (service.version != null)
            {
                this.addPropertyRow(table, "Service Version", Format.formatString(service.version));
            }

            this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));

            this.addPropertyRow(table, "Service Description", Format.formatString(service.description));
            this.addPropertyRow(table, "Service Bindable", Format.formatString(service.bindable));

            if (service.extra != null)
            {
                this.addPropertyRow(table, "Service Extra", Format.formatString(service.extra));
            }

            if (service.tags != null && service.tags.length > 0)
            {
                for (var serviceTagIndex = 0; serviceTagIndex < service.tags.length; serviceTagIndex++)
                {
                    var serviceTag = service.tags[serviceTagIndex];

                    this.addPropertyRow(table, "Service Tag", Format.formatString(serviceTag));
                }
            }

            if (service.documentation_url != null)
            {
                var documentationLink = document.createElement("a");
                $(documentationLink).attr("target", "_blank");
                $(documentationLink).attr("href", service.documentation_url);
                $(documentationLink).addClass("tableLink");
                $(documentationLink).html(service.documentation_url);

                this.addRow(table, "Service Documentation URL", documentationLink);
            }

            if (service.info_url != null)
            {
                var infoLink = document.createElement("a");
                $(infoLink).attr("target", "_blank");
                $(infoLink).attr("href", service.info_url);
                $(infoLink).addClass("tableLink");
                $(infoLink).html(service.info_url);

                this.addRow(table, "Service Info URL", infoLink);
            }
        }

        if (servicePlan != null)
        {
            var servicePlanLink = document.createElement("a");
            $(servicePlanLink).attr("href", "");
            $(servicePlanLink).addClass("tableLink");
            $(servicePlanLink).html(Format.formatString(servicePlan.name));
            $(servicePlanLink).click(function()
            {
                AdminUI.showServicePlan(servicePlan.name);

                return false;
            });
            this.addRow(table, "Service Plan Name", servicePlanLink);

            this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
            this.addPropertyRow(table, "Service Plan Public", Format.formatString(servicePlan.public));
            this.addPropertyRow(table, "Service Plan Description", Format.formatString(servicePlan.description));

            if (servicePlan.extra != null)
            {
                this.addPropertyRow(table, "Service Plan Extra", Format.formatString(servicePlan.extra));
            }
        }

        if (space != null)
        {
            var spaceLink = document.createElement("a");
	        $(spaceLink).attr("href", "");
	        $(spaceLink).addClass("tableLink");
	        $(spaceLink).html(Format.formatString(space.name));
	        $(spaceLink).click(function()
	        {
	            // Select based on org/space target since space name is not unique.
                    AdminUI.showSpace(Format.formatString(row[10]));

                    return false;
	        });

	        this.addRow(table, "Space", spaceLink);
        }

        if (organization != null)
        {
            var organizationLink = document.createElement("a");
            $(organizationLink).attr("href", "");
            $(organizationLink).addClass("tableLink");
            $(organizationLink).html(Format.formatString(organization.name));
            $(organizationLink).click(function()
            {
                AdminUI.showOrganization(organization.name);

                return false;
            });

            this.addRow(table, "Organization", organizationLink);
        }

        if (bindingsAndApplications != null && bindingsAndApplications.length > 0)
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ServiceInstancesApplicationsTableContainer").show();

            var serviceInstancesApplicationsTableData = [];

            for (var bindingAndApplicationIndex = 0; bindingAndApplicationIndex < bindingsAndApplications.length; bindingAndApplicationIndex++)
            {
                var bindingAndApplication = bindingsAndApplications[bindingAndApplicationIndex];
                var application           = bindingAndApplication.application;
                var serviceBinding        = bindingAndApplication.serviceBinding;

                var applicationRow = [];

                applicationRow.push(application.name);
                applicationRow.push(serviceBinding.created_at);

                // Need both the index and the actual object in the table
                applicationRow.push(bindingAndApplicationIndex);
                applicationRow.push(bindingAndApplication);

                serviceInstancesApplicationsTableData.push(applicationRow);
            }

            this.serviceInstancesApplicationsTable.fnClearTable();
            this.serviceInstancesApplicationsTable.fnAddData(serviceInstancesApplicationsTableData);
        }
    }
}

ServiceInstancesTab.prototype.displayApplicationDetail = function(event, rowIndex)
{
    var row = $("#ServiceInstancesApplicationsTable").dataTable().fnGetData(rowIndex);

    var app = row[3];

    var json = JSON.stringify(app, null, 4);

    var page = window.open("", "_blank", "fullscreen=yes,menubar=no,scrollbars=yes,titlebar=no,toolbar=no");

    if (page != null)
    {
        page.document.write("<pre>" + json + "</pre>");
        page.document.close();
    }

    event.stopPropagation();

    return false;
}

ServiceInstancesTab.prototype.showServiceInstances = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();
    $("#ServiceInstancesApplicationsTableContainer").hide();

    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      false);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     false);
    var serviceBindingsDeferred  = Data.get(Constants.URL__SERVICE_BINDINGS,  false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);
    var servicePlansDeferred     = Data.get(Constants.URL__SERVICE_PLANS,     false);
    var servicesDeferred         = Data.get(Constants.URL__SERVICES,          false);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            false);

    $.when(applicationsDeferred, organizationsDeferred, serviceBindingsDeferred, serviceInstancesDeferred, servicePlansDeferred, servicesDeferred, spacesDeferred).done($.proxy(function(applicationsResult, organizationsResult, serviceBindingsResult, serviceInstancesResult, servicePlansResult, servicesResult, spacesResult)
    {
        var tableData = this.getTableData([applicationsResult, organizationsResult, serviceBindingsResult, serviceInstancesResult, servicePlansResult, servicesResult, spacesResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        this.table.fnFilter(filter);

        this.show();
    },
    this));
}

