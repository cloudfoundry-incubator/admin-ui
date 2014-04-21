
function ApplicationsTab(id)
{
    Tab.call(this, id);
}

ApplicationsTab.prototype = new Tab();

ApplicationsTab.prototype.constructor = ApplicationsTab;

ApplicationsTab.prototype.initialize = function()
{
    this.table = Table.createTable(
        this.id,
        this.getColumns(),
        this.getInitialSort(),
        $.proxy(this.clickHandler, this),
        [
            {
                text: "Start",
                click: $.proxy(function()
                {
                    this.manageApplications('start');
                }, this)
            },
            {
                text: "Stop",
                click: $.proxy(function()
                {
                    this.manageApplications('stop');
                }, this)
            },
            {
                text: "Restart",
                click: $.proxy(function()
                {
                    this.manageApplications('restart');
                }, this)
            }
        ]);

    this.applicationServicesTable = Table.createTable("ApplicationsServices", this.getApplicationServicesColumns(), [[0, "asc"]], null, null);
};

ApplicationsTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

ApplicationsTab.prototype.getInitialSort = function()
{
    return [[5, "desc"]];
};

ApplicationsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "&nbsp;",
                    "sWidth": "6px",
                   "sClass": "cellCenterAlign",
                   "bSortable": false,
                   "mRender": function(value, type)
                   {
                       return '<input type="checkbox" value="' + value + '" onclick="ApplicationsTab.prototype.checkboxClickHandler(event)"></input>';
                   }
               },
               {
                   "sTitle": "Name",
                   "sWidth": "150px",
                   "mRender": Format.formatApplicationName
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Package<br/>State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Instance<br/>State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateNumber
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
                                  if (Format.doFormatting(type))
                                  {
                                      var result = "<div>" + value;

                                      if ((value != null) && (value !== ""))
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

ApplicationsTab.prototype.refresh = function(reload)
{
    var applicationsDeferred  = Data.get(Constants.URL__APPLICATIONS,  reload);
    var spacesDeferred        = Data.get(Constants.URL__SPACES,        reload);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS, reload);
    var deasDeferred          = Data.get(Constants.URL__DEAS,          reload);

    $.when(applicationsDeferred, spacesDeferred, organizationsDeferred, deasDeferred).done($.proxy(function(applicationsResult, spacesResult, organizationsResult, deasResult)
    {
        this.updateData([applicationsResult, spacesResult, organizationsResult, deasResult], reload);

        this.applicationServicesTable.fnDraw();
    },
    this));
};

ApplicationsTab.prototype.getTableData = function(results)
{
    var applications  = results[0].response.items;
    var spaces        = results[1].response.items;
    var organizations = results[2].response.items;
    var deas          = results[3].response.items;

    var spaceMap = [];

    for (var spaceIndex in spaces)
    {
        var space = spaces[spaceIndex];

        spaceMap[space.guid] = space;
    }

    var organizationMap = [];
    
    for (var organizationIndex in organizations)
    {
        var organization = organizations[organizationIndex];

        organizationMap[organization.guid] = organization;
    }

    var tableData = [];
    var appMap    = [];

    for (var applicationIndex in applications)
    {
        var application = applications[applicationIndex];

        var space        = spaceMap[application.space_guid];
        var organization = (space == null) ? null : organizationMap[space.organization_guid];

        var row = [];

        row.push(application.guid);
        row.push(application.name);
        row.push(application.state);

        if (application.package_state != null)
        {
            row.push(application.package_state);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        // Instance State
        Utilities.addEmptyElementsToArray(row, 1);

        // Started and URI
        Utilities.addEmptyElementsToArray(row, 2);

        if (application.buildpack != null)
        {
            row.push(application.buildpack);
        }
        else if (application.detected_buildpack != null)
        {
            row.push(application.detected_buildpack);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        // Instance
        Utilities.addEmptyElementsToArray(row, 1);

        // Used services, memory, disk and CPU.
        Utilities.addEmptyElementsToArray(row, 4);

        row.push(application.memory);
        row.push(application.disk_quota);

        if (organization != null && space != null)
        {
            row.push(organization.name + "/" + space.name);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        // DEA
        Utilities.addEmptyElementsToArray(row, 1);

        // DEA index
        row.push(-1);

        row.push({
                     "application": application,
                     "space": space,
                     "organization": organization
                 });

        appMap[application.guid] = row;

        tableData.push(row);
    }

    var numDEAs = deas.length;

    for (var deaIndex = 0; deaIndex < numDEAs; deaIndex++)
    {
        var dea = deas[deaIndex];

        var data = dea.data;
        var host = data.host;

        var applications = data.instance_registry;

        for (var applicationIndex in applications)
        {
            var application = applications[applicationIndex];

            for (instanceIndex in application)
            {
                var instance       = application[instanceIndex];
                var instance_index = instance.instance_index;

                var row = appMap[instance.application_id];

                // In some cases, we will not find an existing row.  Create the row as much as possible from the DEA data.
                if (row == null)
                {
                    row = [];

                    row.push(instance.application_id);
                    row.push(instance.application_name);

                    // State and Package State not available.
                    Utilities.addEmptyElementsToArray(row, 2);

                    row.push(instance.state);

                    if (instance.state_running_timestamp != null)
                    {
                        row.push(instance.state_running_timestamp * 1000);
                    }
                    else
                    {
                        Utilities.addEmptyElementsToArray(row, 1);
                    }

                    row.push(instance.application_uris);

                    // Buildpack not available.
                    Utilities.addEmptyElementsToArray(row, 1);

                    row.push(instance_index);

                    row.push(instance.services.length);
                    row.push((instance.used_memory_in_bytes != null) ? Utilities.convertBytesToMega(instance.used_memory_in_bytes) : 0);
                    row.push((instance.used_disk_in_bytes   != null) ? Utilities.convertBytesToMega(instance.used_disk_in_bytes)   : 0);
                    row.push((instance.computed_pcpu        != null) ? (instance.computed_pcpu * 100)                              : 0);

                    row.push(instance.limits.mem);
                    row.push(instance.limits.disk);

                    // Clear space and organization in case not found below.  Otherwise we potentially have old data
                    var space        = null;
                    var organization = null;

                    if (instance.tags != null && instance.tags.space != null)
                    {
                        space = spaceMap[instance.tags.space];

                        if (space != null)
                        {
                            organization = organizationMap[space.organization_guid];
                        }
                    }

                    if (organization != null && space != null)
                    {
                        row.push(organization.name + "/" + space.name);
                    }
                    else
                    {
                        Utilities.addEmptyElementsToArray(row, 1);
                    }

                    row.push(host);
                    row.push(deaIndex);

                    // No application to push.  Push the instance instead so we can provide details.
                    row.push({
                                 "instance": instance,
                                 "space": space,
                                 "organization": organization
                             });
                    tableData.push(row);
                }
                else
                {
                    // We will add instance info to the 0th row, but other instances have to be cloned so we can have instance specific information
                    if (instance_index > 0)
                    {
                        var newRow = [];
                        for (var index = 0; index < row.length; index++)
                        {
                            newRow.push(row[index]);
                        }

                        tableData.push(newRow);

                        row = newRow;
                    }

                    row[4] = instance.state;

                    if (instance.state_running_timestamp != null)
                    {
                        row[5] = instance.state_running_timestamp * 1000;
                    }

                    row[ 6] = instance.application_uris;
                    row[ 8] = instance_index;
                    row[ 9] = instance.services.length;
                    row[10] = (instance.used_memory_in_bytes != null) ? Utilities.convertBytesToMega(instance.used_memory_in_bytes) : 0;
                    row[11] = (instance.used_disk_in_bytes   != null) ? Utilities.convertBytesToMega(instance.used_disk_in_bytes)   : 0;
                    row[12] = (instance.computed_pcpu        != null) ? (instance.computed_pcpu * 100)                              : 0;
                    row[16] = host;
                    row[17] = deaIndex;

                    // Need the specific instance for this row
                    row[18] = {
                                  "application": row[18].application,
                                  "instance": instance,
                                  "space": row[18].space,
                                  "organization": row[18].organization
                              };
                }
            }
        }
    }

    return tableData;
};

ApplicationsTab.prototype.clickHandler = function()
{
    var tableTools = TableTools.fnGetInstance("ApplicationsTable");

    var selected = tableTools.fnGetSelectedData();

    this.hideDetails();

    $("#ApplicationsServicesTableContainer").hide();

    if (selected.length > 0)
    {
        $("#ApplicationsDetailsLabel").show();

        var containerDiv = $("#ApplicationsPropertiesContainer").get(0);

        var table = this.createPropertyTable(containerDiv);

        var row = selected[0];

        var objects = row[18];

        var application  = objects.application;
        var instance     = objects.instance;
        var space        = objects.space;
        var organization = objects.organization;

        // Cannot assume both application and instance provided.  Could be both or only application or only instance.

        this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[1]), objects, true);

        if (row[2] != "")
        {
            this.addPropertyRow(table, "State", Format.formatString(row[2]));
        }

        if (row[3] != "")
        {
            this.addPropertyRow(table, "Package State", Format.formatString(row[3]));
        }

        if (row[5] != "")
        {
            this.addPropertyRow(table, "Started", Format.formatDateNumber(row[5]));
        }

        var appURIs = row[6];
        if (appURIs != "")
        {
            for (var index = 0; index < appURIs.length; index++)
            {
                var uri = "http://" + appURIs[index];

                var link = document.createElement("a");
                $(link).attr("target", "_blank");
                $(link).attr("href", uri);
                $(link).addClass("tableLink");
                $(link).html(uri);

                this.addRow(table, "URI", link);
            }
        }

        if (row[7] != "")
        {
            var buildpackArray = row[7].split(",");
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

        // Have to use !== or otherwise index of 0 will not qualify.
        if (row[8] !== "")
        {
            this.addPropertyRow(table, "Instance Index", Format.formatNumber(row[8]));
        }

        if (instance != null)
        {
            this.addPropertyRow(table, "Instance State", Format.formatString(instance.state));
        }

        if (application != null && application.droplet_hash != null)
        {
            this.addPropertyRow(table, "Droplet Hash", Format.formatString(application.droplet_hash));
        }
        else if (instance != null && instance.droplet_sha1 != null)
        {
            this.addPropertyRow(table, "Droplet Hash", Format.formatString(instance.droplet_sha1));
        }

        // Have to use !== or otherwise index of 0 will not qualify.
        if (row[9] !== "")
        {
            this.addPropertyRow(table, "Services Used", Format.formatNumber(row[9]));
        }
 
        this.addPropertyRow(table, "Memory Used", Format.formatNumber(row[10]));
        this.addPropertyRow(table, "Disk Used",   Format.formatNumber(row[11]));
        this.addPropertyRow(table, "CPU Used",    Format.formatNumber(row[12]));

        this.addPropertyRow(table, "Memory Reserved",  Format.formatNumber(row[13]));
        this.addPropertyRow(table, "Disk Reserved",    Format.formatNumber(row[14]));

        if (space != null)
        {
            var spaceLink = document.createElement("a");
            $(spaceLink).attr("href", "");
            $(spaceLink).addClass("tableLink");
            $(spaceLink).html(Format.formatString(space.name));
            $(spaceLink).click(function()
            {
                // Select based on org/space target since space name is not unique.
                AdminUI.showSpace(Format.formatString(row[15]));

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
                AdminUI.showOrganization(Format.formatString(organization.name));

                return false;
            });

            this.addRow(table, "Organization", organizationLink);
        }

        if (row[16] != "")
        {
            var dea = Format.formatString(row[16]);
            var deaLink = document.createElement("a");
            $(deaLink).attr("href", "");
            $(deaLink).addClass("tableLink");
            $(deaLink).html(dea);
            $(deaLink).click(function()
            {
                AdminUI.showDEA(row[17]);

                return false;

            });
            this.addRow(table, "DEA", deaLink);
        }

        if (instance != null && instance.services != null)
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
    }
};

ApplicationsTab.prototype.showApplications = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();
    $("#ApplicationsServicesTableContainer").hide();

    var applicationsDeferred  = Data.get(Constants.URL__APPLICATIONS,  false);
    var spacesDeferred        = Data.get(Constants.URL__SPACES,        false);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS, false);
    var deasDeferred          = Data.get(Constants.URL__DEAS,          false);

    $.when(applicationsDeferred, spacesDeferred, organizationsDeferred, deasDeferred).done($.proxy(function(applicationsResult, spacesResult, organizationsResult, deasResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, organizationsResult, deasResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        this.table.fnFilter(filter);

        this.show();
    },
    this));
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

    AdminUI.showModalDialog({ "body": $('<label>"Performing operation, please wait..."</label>') });

    var error_apps = [];

    for (var step = 0; step < apps.length; step ++)
    {
        var app = apps[step];

        var type = "PUT";
        var url = "/applications/" + app;

        var successCallback = function(data){};
        var errorCallback = function(msg)
        {
            error_apps.push(app);
        };

        if (operation == 'start')
        {
            this.sendSyncRequest(type, url, '{"state":"STARTED"}', successCallback, errorCallback);
        }
        else if (operation == 'stop')
        {
            this.sendSyncRequest(type, url, '{"state":"STOPPED"}', successCallback, errorCallback);
        }
        else if (operation == 'restart')
        {
            this.sendSyncRequest(type, url, '{"state":"STOPPED"}', successCallback, errorCallback);
            this.sendSyncRequest(type, url, '{"state":"STARTED"}', successCallback, errorCallback);
        }
    }

    AdminUI.closeModalDialog();

    if(error_apps.length > 0)
    {
        alert("Error handling the following applications:\n" + error_apps);
    }
    else
    {
        // Todos: we need to implement a polling backend service to get the latest app data in the future
        alert("The operation finished without error.\nPlease refresh the page later for the updated result.");
    }

    AdminUI.refresh();
};

ApplicationsTab.prototype.sendSyncRequest = function(type, url, body, successCallback, errorCallback)
{
    $.ajax({
        type: type,
        async: false,
        url: url,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: body,
        success: successCallback,
        error: errorCallback
    });
};

ApplicationsTab.prototype.getSelectedApps = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        alert("Please select at least one row!");
        return null;
    }

    var apps = [];

    for (var step = 0; step < checkedRows.length; step ++)
    {
        apps.push(checkedRows[step].value);
    }

    return apps;
};
