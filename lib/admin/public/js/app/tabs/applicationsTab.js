
function ApplicationsTab(id)
{
    Tab.call(this, id, Constants.URL__APPLICATIONS_VIEW_MODEL);
}

ApplicationsTab.prototype = new Tab();

ApplicationsTab.prototype.constructor = ApplicationsTab;

ApplicationsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

ApplicationsTab.prototype.getColumns = function()
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
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Package State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "URIs",
                   "sWidth": "200px",
                   "mRender": Format.formatURIs
               },
               {
                   "sTitle": "Stack",
                   "sWidth": "200px",
                   "mRender": Format.formatStackName
               },
               {
                   "sTitle": "Buildpacks",
                   "sWidth": "100px",
                   "mRender": Format.formatBuildpacks
               },
               {
                   "sTitle":  "Events",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Instances",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Service Bindings",
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
               }
           ];
};

ApplicationsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Start",
                   click: $.proxy(function()
                   {
                       this.manageApplications("start");
                   }, 
                   this)
               },
               {
                   text: "Stop",
                   click: $.proxy(function()
                   {
                       this.manageApplications("stop");
                   }, 
                   this)
               },
               {
                   text: "Restart",
                   click: $.proxy(function()
                   {
                       this.manageApplications("restart");
                   }, 
                   this)
               },
               {
                   text: "Restage",
                   click: $.proxy(function()
                   {
                       this.manageApplications("restage");
                   }, 
                   this)
               },
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected applications?",
                                          "Delete",
                                          "Deleting Applications",
                                          Constants.URL__APPLICATIONS,
                                          "");
                   }, 
                   this)
               },
               {
                   text: "Delete Recursive",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected applications and their associated service bindings?",
                                          "Delete Recursive",
                                          "Deleting Applications and Associated Service Bindings",
                                          Constants.URL__APPLICATIONS,
                                          "?recursive=true");
                   }, 
                   this)
               }
           ];
};

ApplicationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ApplicationsTab.prototype.showDetails = function(table, objects, row)
{
    var application  = objects.application;
    var organization = objects.organization;
    var space        = objects.space;
    var stack        = objects.stack;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(application.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(application.guid));
    this.addPropertyRow(table, "State", Format.formatString(application.state));
    this.addPropertyRow(table, "Package State", Format.formatString(application.package_state));
    this.addPropertyRow(table, "Created", Format.formatDateString(application.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, application.updated_at);

    var appURIs = row[7];
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
    
    if (row[9] != null)
    {
        var buildpackArray = Utilities.splitByCommas(row[9]);
        for (var buildpackIndex = 0; buildpackIndex < buildpackArray.length; buildpackIndex++)
        {
            var buildpack = buildpackArray[buildpackIndex];
            this.addPropertyRow(table, "Buildpack", Format.formatString(buildpack)); 
        }
    }

    this.addRowIfValue(this.addPropertyRow, table, "Command", Format.formatString, application.command);
    this.addRowIfValue(this.addPropertyRow, "File Descriptors", Format.formatNumber, application.file_descriptors);
    this.addRowIfValue(this.addPropertyRow, table, "Droplet Hash", Format.formatString, application.droplet_hash);

    if (row[10] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[10]), application.guid, AdminUI.showEvents);
    }
    
    if (row[11] != null)
    {
        this.addFilterRow(table, "Instances", Format.formatNumber(row[11]), application.guid, AdminUI.showApplicationInstances);
    }
    
    if (row[12] != null)
    {
        this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[12]), application.guid, AdminUI.showServiceBindings);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",   Format.formatNumber, row[14]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",    Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved",  Format.formatNumber, application.memory);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved", Format.formatNumber, application.disk_quota);

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }
};

ApplicationsTab.prototype.manageApplications = function(operation)
{
    var apps = this.getChecked();

    if (!apps || apps.length == 0)
    {
        return;
    }

    var processed = 0;
    
    var errorApps = [];
    
    var alwaysCallback = function(xhr, status, error)
    {
        processed++;
        
        if (processed == apps.length)
        {
            if (errorApps.length > 0)
            {
                AdminUI.showModalDialogErrorTable(errorApps);
            }
            else
            {
                AdminUI.showModalDialogSuccess();
            }
    
            AdminUI.refresh();
        }
    };

    AdminUI.showModalDialogProgress("Managing Applications");

    for (var appIndex = 0; appIndex < apps.length; appIndex++)
    {
        var app = apps[appIndex];

        var url = Constants.URL__APPLICATIONS + "/" + app.key;

        var failCallback = function(xhr, status, error)
        {
            errorApps.push({
                               label: this.applicationName,
                               xhr:   xhr
                           });
        };

        if (operation == "start")
        {
            this.sendAjaxRequest(app.name, "PUT", url, '{"state":"STARTED"}', failCallback, alwaysCallback);
        }
        else if (operation == "stop")
        {
            this.sendAjaxRequest(app.name, "PUT", url, '{"state":"STOPPED"}', failCallback, alwaysCallback);
        }
        else if (operation == "restart")
        {
            this.sendAjaxRequest(app.name, "PUT", url, '{"state":"STOPPED"}', failCallback, alwaysCallback);
            this.sendAjaxRequest(app.name, "PUT", url, '{"state":"STARTED"}', failCallback, alwaysCallback);
        }
        else if (operation == "restage")
        {
            this.sendAjaxRequest(app.name, "POST", url + "/restage", "{}", failCallback, alwaysCallback);
        }
        else
        {
            return;
        }
    }
};

ApplicationsTab.prototype.sendAjaxRequest = function(applicationName, type, url, body, failCallback, alwaysCallback)
{
    var deferred = $.ajax({
                              type:            type,
                              url:             url,
                              contentType:     "application/json; charset=utf-8",
                              dataType:        "json",
                              data:            body,
                              // Need application name inside the fail method
                              applicationName: applicationName
                          });
    
    deferred.fail(failCallback);
    deferred.always(alwaysCallback);
};
