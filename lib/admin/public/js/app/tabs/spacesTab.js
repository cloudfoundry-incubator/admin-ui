
function SpacesTab(id)
{
    Tab.call(this, id);
}

SpacesTab.prototype = new Tab();

SpacesTab.prototype.constructor = SpacesTab;

SpacesTab.prototype.getInitialSort = function()
{
    return [[4, "desc"]];
}

SpacesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Name",
                   "sWidth": "100px",
                   "mRender": Format.formatSpaceName
               },
               {
                   "sTitle": "Organization",
                   "sWidth": "100px",
                   "mRender": Format.formatOrganizationName
               },
               {
                   "sTitle": "Target",
                   "sWidth": "200px",
                   "mRender": Format.formatTarget
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatDateString
               },
               {
                   "sTitle":  "Developers",
                   "sWidth":  "90px",
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
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Staged",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Failed",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "sType":   "formatted-num",
                   "mRender": Format.formatNumber
               }
           ];
}

SpacesTab.prototype.refresh = function(reload)
{
    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      reload);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            reload);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, reload);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     reload);
    
    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult)
    {
        this.updateData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult], reload);
    },
    this));
}

SpacesTab.prototype.getTableData = function(results)
{
    var applications  = results[0].response.items;
    var spaces        = results[1].response.items;
    var developers    = results[2].response.items;
    var organizations = results[3].response.items;

    var organizationMap = [];
    
    for (var organizationIndex in organizations)
    {
        var organization = organizations[organizationIndex];

        organizationMap[organization.guid] = organization;
    }

    var spaceDeveloperCounters = [];

    for (var developerIndex in developers)
    {
        var developer = developers[developerIndex];

        var space_guid = developer.space_guid;

        if (spaceDeveloperCounters[space_guid] == undefined)
        {
            spaceDeveloperCounters[space_guid] = 0;
        }

        spaceDeveloperCounters[space_guid]++;
    }

    var spaceCountersMap = [];

    for (var applicationIndex in applications)
    {
        var application = applications[applicationIndex];

        var space_guid = application.space_guid;

        var spaceCounters = spaceCountersMap[space_guid];

        if (spaceCounters == undefined)
        {
             spaceCounters = 
             {
                 "total" : 0
             };

             spaceCountersMap[space_guid] = spaceCounters;
        }

        if (spaceCounters[application.state] == null)
        {
            spaceCounters[application.state] = 0;
        }

        if (spaceCounters[application.package_state] == null)
        {
            spaceCounters[application.package_state] = 0;
        }

        spaceCounters.total++;
        spaceCounters[application.state]++;
        spaceCounters[application.package_state]++;
    }

    var tableData = [];

    for (var spaceIndex in spaces)
    {
        var space                 = spaces[spaceIndex];
        var organization          = organizationMap[space.organization_guid];
        var spaceDeveloperCounter = spaceDeveloperCounters[space.guid];
        var spaceCounters         = spaceCountersMap[space.guid];

        var row = [];

        row.push(space.name);
        row.push(organization.name);
        row.push(organization.name + "/" + space.name);
        row.push(space.created_at);
        row.push(spaceDeveloperCounter || 0);

        if (spaceCounters)
        {
            row.push(spaceCounters.total);
            row.push(spaceCounters[Constants.STATUS__STARTED] || 0);
            row.push(spaceCounters[Constants.STATUS__STOPPED] || 0);
            row.push(spaceCounters[Constants.STATUS__PENDING] || 0);
            row.push(spaceCounters[Constants.STATUS__STAGED]  || 0);
            row.push(spaceCounters[Constants.STATUS__FAILED]  || 0);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 6);
        }

        row.push(space);

        tableData.push(row);
    }

    return tableData;
}

SpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(11, true);
}

SpacesTab.prototype.showDetails = function(table, space, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(space.name), space, true);

    var organizationLink = document.createElement("a");
    $(organizationLink).attr("href", "");
    $(organizationLink).addClass("tableLink");
    $(organizationLink).html(Format.formatString(row[1]));
    $(organizationLink).click(function()
    {
        AdminUI.showOrganization(row[1]);

        return false;
    });

    this.addRow(table, "Organization", organizationLink);

    this.addPropertyRow(table, "Created", Format.formatDateString(space.created_at));

    var developersLink = document.createElement("a");
    $(developersLink).attr("href", "");
    $(developersLink).addClass("tableLink");
    $(developersLink).html(Format.formatNumber(row[4]));
    $(developersLink).click(function()
    {
        AdminUI.showDevelopers(Format.formatString(row[2]));

        return false;
    });
    this.addRow(table, "Developers", developersLink);

    var appsLink = document.createElement("a");
    $(appsLink).attr("href", "");
    $(appsLink).addClass("tableLink");
    $(appsLink).html(Format.formatNumber(row[5]));
    $(appsLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(row[2]));

        return false;
    });
    this.addRow(table, "Total Apps", appsLink);

    this.addPropertyRow(table, "Started Apps", Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Stopped Apps", Format.formatNumber(row[7]));
    this.addPropertyRow(table, "Pending Apps", Format.formatNumber(row[8]));
    this.addPropertyRow(table, "Staged Apps",  Format.formatNumber(row[9]));
    this.addPropertyRow(table, "Failed Apps",  Format.formatNumber(row[10]));
}

SpacesTab.prototype.showSpace = function(target)
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
    
    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        for (var index = 0; index < tableData.length; index++)
        {
            var row = tableData[index];

            if (row[2] == target)
            {           
                // Select the space.
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

SpacesTab.prototype.showSpaces = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      false);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            false);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, false);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     false);
    
    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        this.table.fnFilter(filter);

        this.show();
    },
    this));
}

