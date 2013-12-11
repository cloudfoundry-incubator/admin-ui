
function OrganizationsTab(id)
{
    Tab.call(this, id);
}

OrganizationsTab.prototype = new Tab();

OrganizationsTab.prototype.constructor = OrganizationsTab;

OrganizationsTab.prototype.getInitialSort = function()
{
    return [[3, "desc"]];
}

OrganizationsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Name",
                   "sWidth": "100px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle":  "Status",
                   "sWidth":  "80px",
                   "mRender": Format.formatOrganizationStatus
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Spaces",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Developers",
                   "sWidth":  "90px",
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
                   "sTitle":  "Services",
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
                   "sTitle":  "Total",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Stopped",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Pending",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Staged",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Failed",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
}

OrganizationsTab.prototype.refresh = function(reload)
{
    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      reload);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            reload);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, reload);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     reload);
    var deasDeferred             = Data.get(Constants.URL__DEAS,              reload);

    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult)
    {
        this.updateData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult], reload);
    },
    this));
}

OrganizationsTab.prototype.getTableData = function(results)
{
    var applications  = results[0].response.items;
    var spaces        = results[1].response.items;
    var developers    = results[2].response.items;
    var organizations = results[3].response.items;
    var deas          = results[4].response.items;

    var spaceMap = [];
    var organizationSpaceCounters = [];
    var organizationDeveloperCounters = [];

    for (var spaceIndex in spaces)
    {
        var space = spaces[spaceIndex];

        spaceMap[space.guid] = space;

        var organization_guid = space.organization_guid;

        if (organizationSpaceCounters[organization_guid] == undefined)
        {
            organizationSpaceCounters[organization_guid] = 0;
        }

        organizationSpaceCounters[organization_guid]++;
    }

    for (var developerIndex in developers)
    {
        var developer = developers[developerIndex];

        var space = spaceMap[developer.space_guid];

        if (space != null)
        {
            var organization_guid = space.organization_guid;

            if (organizationDeveloperCounters[organization_guid] == undefined)
            {
                organizationDeveloperCounters[organization_guid] = 0;
            }

            organizationDeveloperCounters[organization_guid]++;
        }
    }

    var instanceMap = this.getInstanceMap(deas);

    var organizationAppCountersMap = [];

    for (var applicationIndex in applications)
    {
        var application = applications[applicationIndex];

        var space = spaceMap[application.space_guid];

        if (space != null)
        {
            var organization_guid = space.organization_guid;

            var organizationAppCounters = organizationAppCountersMap[organization_guid];

            if (organizationAppCounters == undefined)
            {
                 organizationAppCounters = 
                 {
                     "total"           : 0,
                     "reserved_memory" : 0,
                     "reserved_disk"   : 0,
                     "used_memory"     : 0,
                     "used_disk"       : 0,
                     "used_cpu"        : 0,
                     "instances"       : 0,
                     "services"        : []
                 };

                 organizationAppCountersMap[organization_guid] = organizationAppCounters;
            }

            if (organizationAppCounters[application.state] == null)
            {
                organizationAppCounters[application.state] = 0;
            }

            if (organizationAppCounters[application.package_state] == null)
            {
                organizationAppCounters[application.package_state] = 0;
            }

            this.addInstanceMetrics(organizationAppCounters, application, instanceMap);

            organizationAppCounters.total++;
            organizationAppCounters[application.state]++;
            organizationAppCounters[application.package_state]++;
        }
    }

    var tableData = [];

    for (var organizationIndex in organizations)
    {
        var organization                 = organizations[organizationIndex];
        var organizationDeveloperCounter = organizationDeveloperCounters[organization.guid];
        var organizationSpaceCounter     = organizationSpaceCounters[organization.guid];
        var organizationAppCounters      = organizationAppCountersMap[organization.guid];

        var row = [];

        row.push(organization.name);
        row.push(organization.status);
        row.push(organization.created_at);
        row.push(organizationSpaceCounter || 0);
        row.push(organizationDeveloperCounter || 0);

        if (organizationAppCounters)
        {
            row.push(organizationAppCounters.instances);
            row.push(Object.keys(organizationAppCounters.services).length);
            row.push(Utilities.convertBytesToMega(organizationAppCounters.used_memory));
            row.push(Utilities.convertBytesToMega(organizationAppCounters.used_disk));
            row.push(organizationAppCounters.used_cpu * 100);
            row.push(organizationAppCounters.reserved_memory);
            row.push(organizationAppCounters.reserved_disk);
            row.push(organizationAppCounters.total);
            row.push(organizationAppCounters[Constants.STATUS__STARTED] || 0);
            row.push(organizationAppCounters[Constants.STATUS__STOPPED] || 0);
            row.push(organizationAppCounters[Constants.STATUS__PENDING] || 0);
            row.push(organizationAppCounters[Constants.STATUS__STAGED]  || 0);
            row.push(organizationAppCounters[Constants.STATUS__FAILED]  || 0);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 13);
        }

        row.push(organization);

        tableData.push(row);
    }

    return tableData;
}

OrganizationsTab.prototype.clickHandler = function()
{
    this.itemClicked(18, true);
}

OrganizationsTab.prototype.showDetails = function(table, organization, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), organization, true);

    this.addPropertyRow(table, "Status",          Format.formatString(organization.status).toUpperCase());
    this.addPropertyRow(table, "Created",         Format.formatDateString(organization.created_at));
    this.addPropertyRow(table, "Billing Enabled", Format.formatString(organization.billing_enabled));

    var spacesLink = document.createElement("a");
    $(spacesLink).attr("href", "");
    $(spacesLink).addClass("tableLink");
    $(spacesLink).html(Format.formatNumber(row[3]));
    $(spacesLink).click(function()
    {
        AdminUI.showSpaces(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Spaces", spacesLink);

    var developersLink = document.createElement("a");
    $(developersLink).attr("href", "");
    $(developersLink).addClass("tableLink");
    $(developersLink).html(Format.formatNumber(row[4]));
    $(developersLink).click(function()
    {
        AdminUI.showDevelopers(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Developers", developersLink);

    var instancesLink = document.createElement("a");
    $(instancesLink).attr("href", "");
    $(instancesLink).addClass("tableLink");
    $(instancesLink).html(Format.formatNumber(row[5]));
    $(instancesLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Instances Used", instancesLink);

    var servicesLink = document.createElement("a");
    $(servicesLink).attr("href", "");
    $(servicesLink).addClass("tableLink");
    $(servicesLink).html(Format.formatNumber(row[6]));
    $(servicesLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Services Used", servicesLink);

    this.addPropertyRow(table, "Memory Used",     Format.formatNumber(row[ 7]));
    this.addPropertyRow(table, "Disk Used",       Format.formatNumber(row[ 8]));
    this.addPropertyRow(table, "CPU Used",        Format.formatNumber(row[ 9]));
    this.addPropertyRow(table, "Memory Reserved", Format.formatNumber(row[10]));
    this.addPropertyRow(table, "Disk Reserved",   Format.formatNumber(row[11]));

    var appsLink = document.createElement("a");
    $(appsLink).attr("href", "");
    $(appsLink).addClass("tableLink");
    $(appsLink).html(Format.formatNumber(row[12]));
    $(appsLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Total Apps", appsLink);

    this.addPropertyRow(table, "Started Apps",    Format.formatNumber(row[13]));
    this.addPropertyRow(table, "Stopped Apps",    Format.formatNumber(row[14]));
    this.addPropertyRow(table, "Pending Apps",    Format.formatNumber(row[15]));
    this.addPropertyRow(table, "Staged Apps",     Format.formatNumber(row[16]));
    this.addPropertyRow(table, "Failed Apps",     Format.formatNumber(row[17]));

}

OrganizationsTab.prototype.showOrganization = function(organizationName)
{
    // Several calls in this function trigger a saveTableScrollPosition() which corrupts the scroll position.
    Table.ignoreScroll = true;

    // Save and clear the sorting so we can select by index.
    var sorting = this.table.fnSettings().aaSorting;
    this.table.fnSort([]);


    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      false);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            false);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, false);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     false);
    var deasDeferred             = Data.get(Constants.URL__DEAS,              false);

    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        for (var index = 0; index < tableData.length; index++)
        {
            var row = tableData[index];

            if (row[0] == organizationName)
            {           
                // Select the organization.
                Table.selectTableRow(this.table, index);

                // Restore the sorting.
                this.table.fnSort(sorting);

                // Move to the Spaces tab.
                AdminUI.setTabSelected(this.id);

                // Show the Spaces tab contents.
                this.show();

                Table.ignoreScroll = false;

                Table.scrollSelectedTableRowIntoView(this.id);                  

                break;
            }
        }
    },
    this));
}

