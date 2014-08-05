
function ServiceInstancesTab(id)
{
    Tab.call(this, id, Constants.URL__SERVICE_INSTANCES_VIEW_MODEL);
}

ServiceInstancesTab.prototype = new Tab();

ServiceInstancesTab.prototype.constructor = ServiceInstancesTab;

ServiceInstancesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceInstancesApplicationsTable = Table.createTable("ServiceInstancesApplications", this.getApplicationColumns(), [[0, "asc"]], null, null, null);
};

ServiceInstancesTab.prototype.getInitialSort = function()
{
    return [[12, "asc"]];
};

ServiceInstancesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
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
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Public",
                   "sWidth":  "70px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
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
};

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
};

ServiceInstancesTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);
    
    $("#ServiceInstancesApplicationsTableContainer").hide();
};

ServiceInstancesTab.prototype.clickHandler = function()
{
    this.itemClicked(18, true);
};

ServiceInstancesTab.prototype.showDetails = function(table, target, row)
{
    var bindingsAndApplications = target.bindingsAndApplications;
    var organization            = target.organization;
    var service                 = target.service;
    var serviceBroker           = target.serviceBroker;
    var serviceInstance         = target.serviceInstance;
    var servicePlan             = target.servicePlan;
    var space                   = target.space;

    this.addJSONDetailsLinkRow(table, "Service Instance Name", Format.formatString(serviceInstance.name), target, true);
    this.addPropertyRow(table, "Service Instance Created", Format.formatDateString(serviceInstance.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Instance Updated", Format.formatDateString, serviceInstance.updated_at);
    
    if (serviceInstance.dashboard_url != null)
    {
        var dashboardLink = document.createElement("a");
        $(dashboardLink).attr("target", "_blank");
        $(dashboardLink).attr("href", serviceInstance.dashboard_url);
        $(dashboardLink).addClass("tableLink");
        $(dashboardLink).html(serviceInstance.dashboard_url);

        this.addRow(table, "Service Instance Dashboard URL", dashboardLink);
    }

    if (serviceBroker != null)
    {
        this.addPropertyRow(table, "Service Broker Name", Format.formatString(serviceBroker.name));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }

    if (service != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
        this.addPropertyRow(table, "Service Label", Format.formatString(service.label));
        this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
        this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
        this.addPropertyRow(table, "Service Description", Format.formatString(service.description));
        this.addPropertyRow(table, "Service Bindable", Format.formatString(service.bindable));
        this.addRowIfValue(this.addPropertyRow, table, "Service Extra", Format.formatString, service.extra);

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
        $(servicePlanLink).html(Format.formatStringCleansed(servicePlan.name));
        $(servicePlanLink).click(function()
        {
            AdminUI.showServicePlans(Format.formatString(row[12]));

            return false;
        });
        this.addRow(table, "Service Plan Name", servicePlanLink);

        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addPropertyRow(table, "Service Plan Public", Format.formatString(servicePlan.public));
        this.addPropertyRow(table, "Service Plan Description", Format.formatString(servicePlan.description));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Extra", Format.formatString, servicePlan.extra);
    }

    if (space != null)
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(space.name));
        $(spaceLink).click(function()
        {
            // Select based on org/space target since space name is not unique.
            AdminUI.showSpaces(Format.formatString(row[17]));

            return false;
        });

        this.addRow(table, "Space", spaceLink);
    }

    if (organization != null)
    {
        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatStringCleansed(organization.name));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganizations(organization.name);

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
};

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
};
