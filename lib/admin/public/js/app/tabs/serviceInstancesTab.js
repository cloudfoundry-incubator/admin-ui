
function ServiceInstancesTab(id)
{
    Tab.call(this, id, Constants.URL__SERVICE_INSTANCES_VIEW_MODEL);
}

ServiceInstancesTab.prototype = new Tab();

ServiceInstancesTab.prototype.constructor = ServiceInstancesTab;

ServiceInstancesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.serviceInstancesApplicationsTable = Table.createTable("ServiceInstancesApplications", this.getApplicationColumns(), [[0, "asc"]], null, null, null, null);
};

ServiceInstancesTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
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
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sTitle":  "Active",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Public",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Free",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
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
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sTitle": "Active",
                   "sWidth": "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Bindable",
                   "sWidth":  "70px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sWidth":  "150px",
                   "mRender": function(name, type, row)
                   {
                       var appName = Format.formatApplicationName(name, type);
                       
                       if (Format.doFormatting(type))
                       {
                           return "<a class='tableLink' onclick='AdminUI.showApplications(\"" + 
                                  row[1] +  
                                  "\")'>" + 
                                  appName + 
                                  "</a><img onclick='ServiceInstancesTab.prototype.displayApplicationDetail(event, \"" + 
                                  row[3] + 
                                  "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                       }

                       return appName;
                   }
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
    this.itemClicked(-1, 1);
};

ServiceInstancesTab.prototype.showDetails = function(table, objects, row)
{
    var bindingsAndApplications = objects.bindingsAndApplications;
    var organization            = objects.organization;
    var service                 = objects.service;
    var serviceBroker           = objects.serviceBroker;
    var serviceInstance         = objects.serviceInstance;
    var servicePlan             = objects.servicePlan;
    var space                   = objects.space;

    this.addJSONDetailsLinkRow(table, "Service Instance Name", Format.formatString(serviceInstance.name), objects, true);
    this.addPropertyRow(table, "Service Instance GUID", Format.formatString(serviceInstance.guid));
    this.addPropertyRow(table, "Service Instance Created", Format.formatDateString(serviceInstance.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Instance Updated", Format.formatDateString, serviceInstance.updated_at);
    
    if (serviceInstance.dashboard_url != null)
    {
        this.addURIRow(table, "Service Instance Dashboard URL", serviceInstance.dashboard_url);
    }
    
    if (servicePlan != null)
    {
        this.addFilterRow(table, "Service Plan Name", Format.formatStringCleansed(servicePlan.name), servicePlan.guid, AdminUI.showServicePlans);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addPropertyRow(table, "Service Plan Active", Format.formatBoolean(servicePlan.active));
        this.addPropertyRow(table, "Service Plan Public", Format.formatBoolean(servicePlan.public));
        this.addPropertyRow(table, "Service Plan Free", Format.formatBoolean(servicePlan.free));
    }

    if (service != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
        this.addFilterRow(table, "Service Label", Format.formatStringCleansed(service.label), service.guid, AdminUI.showServices);
        this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
        this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
        this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
        this.addPropertyRow(table, "Service Bindable", Format.formatBoolean(service.bindable));
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
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
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
            applicationRow.push(application.guid);
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

    var app = row[4];

    Utilities.windowOpen(app);
    
    event.stopPropagation();

    return false;
};
