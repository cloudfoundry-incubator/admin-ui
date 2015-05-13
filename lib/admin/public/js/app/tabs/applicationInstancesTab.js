
function ApplicationInstancesTab(id)
{
    Tab.call(this, id, Constants.URL__APPLICATION_INSTANCES_VIEW_MODEL);
}

ApplicationInstancesTab.prototype = new Tab();

ApplicationInstancesTab.prototype.constructor = ApplicationInstancesTab;

ApplicationInstancesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.applicationInstancesServicesTable = Table.createTable("ApplicationInstancesServices", this.getApplicationInstanceServicesColumns(), [[0, "asc"]], null, null, null, null);
};

ApplicationInstancesTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

ApplicationInstancesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       return Tab.prototype.formatCheckbox(item[1], value);
                   }
               },
               {
                   "sTitle": "Name",
                   "sWidth": "150px",
                   "mRender": Format.formatApplicationName
               },
               {
                   "sTitle": "Application GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Index",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "URI",
                   "sWidth": "200px",
                   "mRender": Format.formatURIs
               },
               {
                   "sTitle": "Stack",
                   "sWidth": "200px",
                   "mRender": Format.formatStackName
               },
               {
                   "sTitle":  "Services",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "% CPU",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Memory",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
               },
               {
                   "sTitle": "DEA",
                   "sWidth": "150px",
                   "mRender": function(value, type)
                   {
                       if (value == null)
                       {
                           return "";
                       }
                      
                       if (Format.doFormatting(type))
                       {
                           var result = "<div>" + value;

                           if (value != null)
                           {
                               result += "<img onclick='ApplicationInstancesTab.prototype.filterApplicationInstanceTable(event, \"" + value + "\");' src='images/filter.png' style='height: 16px; width: 16px; margin-left: 5px; vertical-align: middle;'>";
                           }

                           result += "</div>";

                           return result;
                       }
                       else
                       {
                           return value;
                       }
                   }
               }
           ];
};

ApplicationInstancesTab.prototype.getApplicationInstanceServicesColumns = function()
{
    return [
               {
                   "sTitle":  "Instance Name",
                   "sWidth":  "200px",
                   "mRender": function(name, type, row)
                   {
                       var serviceName = Format.formatServiceString(name, type);
                       
                       if (Format.doFormatting(type))
                       {
                           return serviceName + 
                                  "<img onclick='ApplicationInstancesTab.prototype.displayApplicationInstanceServiceDetail(event, \"" + 
                                  row[5] + 
                                  "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                       }

                       return serviceName;
                   }
               },
               {
                   "sTitle":  "Provider",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Service Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
               {
                   "sTitle":  "Plan Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               }
           ];
};

ApplicationInstancesTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);
    
    $("#ApplicationInstancesServicesTableContainer").hide();
};

ApplicationInstancesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2, 3);
};

ApplicationInstancesTab.prototype.showDetails = function(table, objects, row)
{
    var application_instance = objects.application_instance;
    var organization         = objects.organization;
    var space                = objects.space;
    var stack                = objects.stack;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[1]), objects, true);
    this.addFilterRow(table, "Application GUID", Format.formatString(application_instance.application_id), application_instance.application_id, AdminUI.showApplications);
    this.addPropertyRow(table, "Index", Format.formatNumber(application_instance.instance_index));
    this.addPropertyRow(table, "State", Format.formatString(application_instance.state));

    this.addRowIfValue(this.addPropertyRow, table, "Started", Format.formatDateNumber, row[5]);

    var appURIs = row[6];
    if (appURIs != null)
    {
        for (var appURIIndex = 0; appURIIndex < appURIs.length; appURIIndex++)
        {
            this.addURIRow(table, "URI", "http://" + appURIs[appURIIndex]);
        }
    }

    if (stack != null)
    {
        this.addFilterRow(table, "Stack", Format.formatStringCleansed(stack.name), stack.guid, AdminUI.showStacks);
    }

    if (application_instance.droplet_sha1 != null)
    {
        this.addPropertyRow(table, "Droplet Hash", Format.formatString(application_instance.droplet_sha1));
    }

    this.addRowIfValue(this.addPropertyRow, table, "Services Used", Format.formatNumber, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[9]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",   Format.formatNumber, row[10]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",    Format.formatNumber, row[11]);
    this.addPropertyRow(table, "Memory Reserved",  Format.formatNumber(row[12]));
    this.addPropertyRow(table, "Disk Reserved",    Format.formatNumber(row[13]));

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }

    if (row[15] != null)
    {
        this.addFilterRow(table, "DEA", Format.formatStringCleansed(row[15]), row[15], AdminUI.showDEAs);
    }

    if (application_instance.services != null && application_instance.services.length > 0)
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ApplicationInstancesServicesTableContainer").show();

        var serviceTableData = [];

        for (var serviceIndex = 0; serviceIndex < application_instance.services.length; serviceIndex++)
        {
            var service = application_instance.services[serviceIndex];

            var serviceRow = [];

            serviceRow.push(service.name);

            if ((service.provider != null) || (service.vendor != null) || (service.version != null) || (service.plan != null))
            {
                serviceRow.push(service.provider || "");
                serviceRow.push(service.vendor   || "");
                serviceRow.push(service.version  || "");
                serviceRow.push(service.plan     || "");
            }
            else if (service.label != null)
            {
                // This is likely a user-provided service

                // provider
                Utilities.addEmptyElementsToArray(serviceRow, 1);

                serviceRow.push(service.label);

                // version and plan
                Utilities.addEmptyElementsToArray(serviceRow, 2);
            }
            else
            {
                // provider, vendor, version and plan
                Utilities.addEmptyElementsToArray(serviceRow, 4);
            }

            // Need both the row index and the actual object in the table
            serviceRow.push(serviceIndex);
            serviceRow.push(service);

            serviceTableData.push(serviceRow);
        }

        this.applicationInstancesServicesTable.fnClearTable();
        this.applicationInstancesServicesTable.fnAddData(serviceTableData);
    }
};

ApplicationInstancesTab.prototype.filterApplicationInstanceTable = function(event, value)
{
    var tableTools = TableTools.fnGetInstance("ApplicationInstancesTable");

    tableTools.fnSelectNone();

    $("#ApplicationInstancesTable").dataTable().fnFilter(value);

    event.stopPropagation();

    return false;
};

ApplicationInstancesTab.prototype.displayApplicationInstanceServiceDetail = function(event, rowIndex)
{
    var row = $("#ApplicationInstancesServicesTable").dataTable().fnGetData(rowIndex);

    var service = row[6];

    Utilities.windowOpen(service);

    event.stopPropagation();

    return false;
};
