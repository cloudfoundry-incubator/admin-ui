
function ApplicationsTab(id)
{
    Tab.call(this, id);
}

ApplicationsTab.prototype = new Tab();

ApplicationsTab.prototype.constructor = ApplicationsTab;

ApplicationsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.applicationServicesTable = Table.createTable("ApplicationsServices", this.getApplicationServicesColumns(), [[0, "asc"]], null);
}

ApplicationsTab.prototype.getInitialSort = function()
{
    return [[3, "desc"]];
}

ApplicationsTab.prototype.getColumns = function()
{
    return [
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
                   "sTitle":  "Memory",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Disk",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Instance",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Services",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Space",
                   "sWidth":  "100px",
                   "mRender": Format.formatSpaceName
               },
               {
                   "sTitle":  "Organization",
                   "sWidth":  "100px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "mRender": Format.formatTarget
               },
               {
                   "sTitle": "DEA",
                   "sWidth": "10px",
                   "mRender": function(value)
                              {
                                  var result = value;

                                  if ((value != null) && (value !== ""))
                                  {
                                      result += "<img onclick='ApplicationsTab.prototype.filterApplicationTable(event, \"" + value + "\");' src='images/filter.png' style='margin-left: 5px; vertical-align: middle;'>";
                                  }

                                  return result;
                              }
               }
           ];
}

ApplicationsTab.prototype.getApplicationServicesColumns = function()
{
    return [
               {
                   "sTitle":  "Instance Name",
                   "sWidth":  "150px",
                   "mRender": function(name, type, item)
                              {
                                  return name + "<img onclick='ApplicationsTab.prototype.displayApplicationServiceDetail(event, \"" + item[5] + "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
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
}

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
}

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
        var organization = organizationMap[space.organization_guid];

        var row = [];

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

        // Started and URI
        Utilities.addEmptyElementsToArray(row, 2);

        if (application.detected_buildpack != null)
        {
            row.push(application.detected_buildpack);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(application.memory);
        row.push(application.disk_quota);

        // Instance and Services
        Utilities.addEmptyElementsToArray(row, 2);

        row.push(space.name);
        row.push(organization.name);
        row.push(organization.name + "/" + space.name);

        // DEA
        Utilities.addEmptyElementsToArray(row, 1);

        // DEA index
        row.push(-1);

        row.push({"application": application});

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

                // TODO - We should always find a row, but in some cases, we have not.  Nice to see this row even if not completely filled. 
                // Create the row as much as possible from the DEA data.
                if (row == null)
                {
                    row = [];
                    
                    row.push(instance.application_name);

                    // State and Package State not available.
                    Utilities.addEmptyElementsToArray(row, 2);

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

                    row.push(instance.limits.mem);
                    row.push(instance.limits.disk);
                    row.push(instance_index);
                    row.push(instance.services.length);

                    if (instance.tags != null && instance.tags.space != null && spaceMap[instance.tags.space] != null)
                    {
                        var space        = spaceMap[instance.tags.space];
                        var organization = organizationMap[space.organization_guid];

                        row.push(space.name);
                        row.push(organization.name);
                        row.push(organization.name + "/" + space.name);
                    }
                    else
                    {
                        Utilities.addEmptyElementsToArray(row, 3);
                    }

                    row.push(host);
                    row.push(deaIndex);

                    // No application to push.  Push the instance instead so we can provide details.
                    row.push({"instance": instance});

                    tableData.push(row);
                }
                else
                {
                    if (instance_index > 0)
                    {
                        newRow = [];
                        for (var index = 0; index < row.length; index++)
                        {
                            newRow.push(row[index]);
                        }

                        tableData.push(newRow);

                        row = newRow;
                    }

                    if (instance.state_running_timestamp != null)
                    {
                        row[ 3] = instance.state_running_timestamp * 1000;
                    }

                    row[ 4] = instance.application_uris;
                    row[ 8] = instance_index;
                    row[ 9] = instance.services.length;
                    row[13] = host;
                    row[14] = deaIndex;

                    // Want to copy over the entry with the actual application object since we want a deep clone.
                    row[15] = {"application": row[15].application, "instance": instance};
                }
            }
        }
    }

    return tableData;
}

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

        var applicationAndInstance = row[15];

        var application = applicationAndInstance.application;
        var instance    = applicationAndInstance.instance;

        // Cannot assume both application and instance provided.  Could be both or only application or only instance.

        this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), applicationAndInstance, true);

        if (row[1] != "")
        {
            this.addPropertyRow(table, "State", Format.formatString(row[1]));
        }

        if (row[2] != "")
        {
            this.addPropertyRow(table, "Package State", Format.formatString(row[2]));
        }

        if (row[3] != "")
        {
            this.addPropertyRow(table, "Started", Format.formatDateNumber(row[3]));
        }

        var appURIs = row[4];
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

        if (row[5] != "")
        {
            var buildpackArray = row[5].split(",");
            for (var buildpackIndex = 0; buildpackIndex < buildpackArray.length; buildpackIndex++)
            {
                var buildpack = buildpackArray[buildpackIndex];
                this.addPropertyRow(table, "Buildpack", Format.formatString(buildpack)); 
            }
        }

        this.addPropertyRow(table, "Memory Reserved",  Format.formatNumber(row[6]));
        this.addPropertyRow(table, "Disk Reserved",    Format.formatNumber(row[7]));

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

        // Have to use !== or otherwise index of 0 will not qualify.
        if (row[9] !== "")
        {
            this.addPropertyRow(table, "Services", Format.formatNumber(row[9]));
        }

        if (application != null && application.droplet_hash != null)
        {
            this.addPropertyRow(table, "Droplet Hash", Format.formatString(application.droplet_hash));
        }
        else if (instance != null && instance.droplet_sha1 != null)
        {
            this.addPropertyRow(table, "Droplet Hash", Format.formatString(instance.droplet_sha1));
        }

        if (row[10] != "")
        {
            var spaceLink = document.createElement("a");
            $(spaceLink).attr("href", "");
            $(spaceLink).addClass("tableLink");
            $(spaceLink).html(Format.formatString(row[10]));
            $(spaceLink).click(function()
            {
                // Select based on org/space target since space name is not unique.
                AdminUI.showSpace(Format.formatString(row[12]));

                return false;
            });

            this.addRow(table, "Space", spaceLink);

            var organizationLink = document.createElement("a");
            $(organizationLink).attr("href", "");
            $(organizationLink).addClass("tableLink");
            $(organizationLink).html(Format.formatString(row[11]));
            $(organizationLink).click(function()
            {
                AdminUI.showOrganization(Format.formatString(row[11]));

                return false;
            });

            this.addRow(table, "Organization", organizationLink);
        }

        if (row[13] != "")
        {
            var dea = Format.formatString(row[13]);
            var deaLink = document.createElement("a");
            $(deaLink).attr("href", "");
            $(deaLink).addClass("tableLink");
            $(deaLink).html(dea);
            $(deaLink).click(function()
            {
                AdminUI.showDEA(row[14]);

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
                serviceRow.push(service.provider);
                serviceRow.push(service.vendor);
                serviceRow.push(service.version);
                serviceRow.push(service.plan);

                // Need both the row index and the actual object in the table
                serviceRow.push(serviceIndex);
                serviceRow.push(service);

                serviceTableData.push(serviceRow);
            }

            this.applicationServicesTable.fnClearTable();
            this.applicationServicesTable.fnAddData(serviceTableData);
        }
    }
}

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
}

ApplicationsTab.prototype.filterApplicationTable = function(event, value)
{
    var tableTools = TableTools.fnGetInstance("ApplicationsTable");

    tableTools.fnSelectNone();

    $("#ApplicationsTable").dataTable().fnFilter(value);

    event.stopPropagation();

    return false;
}

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
}

