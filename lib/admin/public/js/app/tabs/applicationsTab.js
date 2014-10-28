
function ApplicationsTab(id)
{
    Tab.call(this, id, Constants.URL__APPLICATIONS_VIEW_MODEL);
}

ApplicationsTab.prototype = new Tab();

ApplicationsTab.prototype.constructor = ApplicationsTab;

ApplicationsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.applicationServicesTable = Table.createTable("ApplicationsServices", this.getApplicationServicesColumns(), [[0, "asc"]], null, null, null, null);
};

ApplicationsTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

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
                   "mRender":   function(value, type)
                   {
                       return "<input type='checkbox' value='" + value + "' onclick='ApplicationsTab.prototype.checkboxClickHandler(event)'></input>";
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
                   "sTitle":  "Instance State",
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
                   "sTitle": "Buildpack",
                   "sWidth": "100px",
                   "mRender": Format.formatBuildpacks
               },
               {
                   "sTitle":  "Instance",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
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
                               result += "<img onclick='ApplicationsTab.prototype.filterApplicationTable(event, \"" + value + "\");' src='images/filter.png' style='height: 16px; width: 16px; margin-left: 5px; vertical-align: middle;'>";
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
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.manageApplications("delete");
                   }, 
                   this)
               }
           ];
};

ApplicationsTab.prototype.getApplicationServicesColumns = function()
{
    return [
               {
                   "sTitle":  "Instance Name",
                   "sWidth":  "150px",
                   "mRender": function(name, type, item)
                   {
                       var result = name;

                       if (Format.doFormatting(type))
                       {
                           result += "<img onclick='ApplicationsTab.prototype.displayApplicationServiceDetail(event, \"" + item[5] + "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                       }

                       return result;
                   }
               },
               {
                   "sTitle":  "Provider",
                   "sWidth":  "150px"
               },
               {
                   "sTitle":  "Service Name",
                   "sWidth":  "150px"
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "70px"
               },
               {
                   "sTitle":  "Plan Name",
                   "sWidth":  "150px"
               }
           ];
};

ApplicationsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);
    
    $("#ApplicationsServicesTableContainer").hide();
};

ApplicationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2, 11);
};

ApplicationsTab.prototype.showDetails = function(table, objects, row)
{
    var application  = objects.application;
    var instance     = objects.instance;
    var space        = objects.space;
    var organization = objects.organization;

    // Cannot assume both application and instance provided.  Could be both or only application or only instance.

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[1]), objects, true);
    this.addRowIfValue(this.addPropertyRow, table, "GUID", Format.formatString, row[2]);
    this.addRowIfValue(this.addPropertyRow, table, "State", Format.formatString, row[3]);
    this.addRowIfValue(this.addPropertyRow, table, "Package State", Format.formatString, row[4]);
    
    if (instance != null)
    {
        this.addPropertyRow(table, "Instance State", Format.formatString(instance.state));
    }

    this.addRowIfValue(this.addPropertyRow, table, "Created", Format.formatDateString, row[6]);
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, row[7]);
    this.addRowIfValue(this.addPropertyRow, table, "Started", Format.formatDateNumber, row[8]);

    var appURIs = row[9];
    if (appURIs != null)
    {
        for (var appURIIndex = 0; appURIIndex < appURIs.length; appURIIndex++)
        {
            var uri = "http://" + appURIs[appURIIndex];

            var link = document.createElement("a");
            $(link).attr("target", "_blank");
            $(link).attr("href", uri);
            $(link).addClass("tableLink");
            $(link).html(uri);

            this.addRow(table, "URI", link);
        }
    }

    if (row[10] != null)
    {
        var buildpackArray = row[10].split(",");
        for (var buildpackIndex = 0; buildpackIndex < buildpackArray.length; buildpackIndex++)
        {
            var buildpack = buildpackArray[buildpackIndex];
            this.addPropertyRow(table, "Buildpack", Format.formatString(buildpack)); 
        }
    }

    if (application != null && application.file_descriptors != null)
    {
        this.addPropertyRow(table, "File Descriptors", Format.formatNumber(application.file_descriptors));
    }

    this.addRowIfValue(this.addPropertyRow, table, "Instance Index", Format.formatNumber, row[11]);

    if (application != null && application.droplet_hash != null)
    {
        this.addPropertyRow(table, "Droplet Hash", Format.formatString(application.droplet_hash));
    }
    else if (instance != null && instance.droplet_sha1 != null)
    {
        this.addPropertyRow(table, "Droplet Hash", Format.formatString(instance.droplet_sha1));
    }

    this.addRowIfValue(this.addPropertyRow, table, "Services Used", Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",   Format.formatNumber, row[14]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",    Format.formatNumber, row[15]);
    this.addPropertyRow(table, "Memory Reserved",  Format.formatNumber(row[16]));
    this.addPropertyRow(table, "Disk Reserved",    Format.formatNumber(row[17]));

    if (space != null)
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(space.name));
        $(spaceLink).click(function()
        {
            // Select based on org/space target since space name is not unique.
            AdminUI.showSpaces(Format.formatString(row[18]));

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
            AdminUI.showOrganizations(Format.formatString(organization.name));

            return false;
        });

        this.addRow(table, "Organization", organizationLink);
    }

    if (row[19] != null)
    {
        var dea = Format.formatString(row[19]);
        var deaLink = document.createElement("a");
        $(deaLink).attr("href", "");
        $(deaLink).addClass("tableLink");
        $(deaLink).html(dea);
        $(deaLink).click(function()
        {
            AdminUI.showDEAs(row[19]);

            return false;

        });
        this.addRow(table, "DEA", deaLink);
    }

    if (instance != null && instance.services != null && instance.services.length > 0)
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ApplicationsServicesTableContainer").show();

        var serviceTableData = [];

        for (var serviceIndex = 0; serviceIndex < instance.services.length; serviceIndex++)
        {
            var service = instance.services[serviceIndex];

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

        this.applicationServicesTable.fnClearTable();
        this.applicationServicesTable.fnAddData(serviceTableData);
    }
};

ApplicationsTab.prototype.filterApplicationTable = function(event, value)
{
    var tableTools = TableTools.fnGetInstance("ApplicationsTable");

    tableTools.fnSelectNone();

    $("#ApplicationsTable").dataTable().fnFilter(value);

    event.stopPropagation();

    return false;
};

ApplicationsTab.prototype.displayApplicationServiceDetail = function(event, rowIndex)
{
    var row = $("#ApplicationsServicesTable").dataTable().fnGetData(rowIndex);

    var service = row[6];

    var json = JSON.stringify(service, null, 4);

    var page = window.open("", "_blank", "fullscreen=yes,menubar=no,scrollbars=yes,titlebar=no,toolbar=no");

    if (page != null)
    {
        page.document.write("<pre>" + json + "</pre>");
        page.document.close();
    }

    event.stopPropagation();

    return false;
};

ApplicationsTab.prototype.manageApplications = function(operation)
{
    var apps = this.getSelectedApps();

    if (!apps || apps.length == 0)
    {
        return;
    }

    var callback = $.proxy(function()
    {
        var processed = 0;
        
        var errorApps = [];
        
        var alwaysCallback = function(xhr, status, error)
        {
            processed++;
            
            if (processed == apps.length)
            {
                if (errorApps.length > 0)
                {
                    var errorDetail = "Error handling the following applications:<br/>";
                    
                    for (var errorIndex = 0; errorIndex < errorApps.length; errorIndex++)
                    {
                        var errorApp = errorApps[errorIndex];
                        
                        errorDetail += "<br/>" + errorApp; 
                    }
                    
                    AdminUI.showModalDialogError(errorDetail);
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
    
            var url = Constants.URL__APPLICATIONS + "/" + app;
    
            var failCallback = function(xhr, status, error)
            {
                errorApps.push(app);
            };
    
            if (operation == "start")
            {
                this.sendAjaxRequest("PUT", url, '{"state":"STARTED"}', failCallback, alwaysCallback);
            }
            else if (operation == "stop")
            {
                this.sendAjaxRequest("PUT", url, '{"state":"STOPPED"}', failCallback, alwaysCallback);
            }
            else if (operation == "restart")
            {
                this.sendAjaxRequest("PUT", url, '{"state":"STOPPED"}', failCallback, alwaysCallback);
                this.sendAjaxRequest("PUT", url, '{"state":"STARTED"}', failCallback, alwaysCallback);
            }
            else if (operation == "delete")
            {
                this.sendAjaxRequest("DELETE", url, null, failCallback, alwaysCallback);
            }
        }
    }, this);
    
    if (operation == "delete")
    {
        AdminUI.showModalDialogConfirmation("Are you sure you want to delete the selected applications?",
                                            "Delete", 
                                            callback);
    }
    else
    {
        callback();
    }
};

ApplicationsTab.prototype.sendAjaxRequest = function(type, url, body, failCallback, alwaysCallback)
{
    var deferred = $.ajax({
                              type:        type,
                              url:         url,
                              contentType: "application/json; charset=utf-8",
                              dataType:    "json",
                              data:        body
                          });
    
    deferred.fail(failCallback);
    deferred.always(alwaysCallback);
};

ApplicationsTab.prototype.getSelectedApps = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var apps = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        apps.push(checkedRows[checkedIndex].value);
    }

    return apps;
};
