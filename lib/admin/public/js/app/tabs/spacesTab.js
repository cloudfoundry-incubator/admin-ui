
function SpacesTab(id)
{
    Tab.call(this, id);
}

SpacesTab.prototype = new Tab();

SpacesTab.prototype.constructor = SpacesTab;

SpacesTab.prototype.getInitialSort = function()
{
    return [[3, "desc"]];
};

SpacesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Name",
                   "sWidth": "100px",
                   "mRender": Format.formatSpaceName
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
                   "sTitle":  "Updated",
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
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Used",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Unused",
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
};

SpacesTab.prototype.refresh = function(reload)
{
    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      reload);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            reload);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, reload);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     reload);
    var deasDeferred             = Data.get(Constants.URL__DEAS,              reload);
    var routesDeferred           = Data.get(Constants.URL__ROUTES,            reload);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, reload);
    
    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred, routesDeferred, serviceInstancesDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult)
    {
        this.updateData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult], reload);
    },
    this));
};

SpacesTab.prototype.getTableData = function(results)
{
    var applications     = results[0].response.items;
    var spaces           = results[1].response.items;
    var developers       = results[2].response.items;
    var organizations    = results[3].response.items;
    var deas             = results[4].response.items;
    var routes           = results[5].response.items;
    var serviceInstances = results[6].response.items;

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

    var spaceServiceInstanceCounters = [];

    for (var serviceInstanceIndex in serviceInstances)
    {
        var serviceInstance = serviceInstances[serviceInstanceIndex];

        var space_guid = serviceInstance.space_guid;

        if (spaceServiceInstanceCounters[space_guid] == undefined)
        {
            spaceServiceInstanceCounters[space_guid] = 0;
        }

        spaceServiceInstanceCounters[space_guid]++;
    }

    var instanceMap = this.getInstanceMap(deas);

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
                 "total"           : 0,
                 "reserved_memory" : 0,
                 "reserved_disk"   : 0,
                 "used_memory"     : 0,
                 "used_disk"       : 0,
                 "used_cpu"        : 0,
                 "instances"       : 0
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

        this.addInstanceMetrics(spaceCounters, application, instanceMap);

        spaceCounters.total++;
        spaceCounters[application.state]++;
        spaceCounters[application.package_state]++;
    }

    var spaceRouteCountersMap = [];

    for (var routeIndex in routes)
    {
        var route = routes[routeIndex];

        var spaceRouteCounters = spaceRouteCountersMap[route.space_guid];

        if (!spaceRouteCounters)
        {
            spaceRouteCounters = [];
            spaceRouteCountersMap[route.space_guid] = spaceRouteCounters;
        }

        if (!spaceRouteCounters['totalRoutes'])
        {
            spaceRouteCounters['totalRoutes'] = 0;
        }

        if (!spaceRouteCounters['unusedRoutes'])
        {
            spaceRouteCounters['unusedRoutes'] = 0;
        }

        if(route.apps.length == 0)
        {
            spaceRouteCounters['unusedRoutes'] ++;
        }

        spaceRouteCounters['totalRoutes'] ++;
    }

    var tableData = [];

    for (var spaceIndex in spaces)
    {
        var space                       = spaces[spaceIndex];
        var organization                = organizationMap[space.organization_guid];
        var spaceDeveloperCounter       = spaceDeveloperCounters[space.guid];
        var spaceServiceInstanceCounter = spaceServiceInstanceCounters[space.guid];
        var spaceCounters               = spaceCountersMap[space.guid];
        var spaceRouteCounters          = spaceRouteCountersMap[space.guid];

        var row = [];

        row.push(space.name);

        if (organization != null)
        {
            row.push(organization.name + "/" + space.name);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(space.created_at);
        if (space.updated_at != null)
        {
            row.push(space.updated_at);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(spaceDeveloperCounter || 0);

        if (spaceRouteCounters)
        {
            row.push(spaceRouteCounters['totalRoutes']);
            row.push(spaceRouteCounters['totalRoutes'] - spaceRouteCounters['unusedRoutes']);
            row.push(spaceRouteCounters['unusedRoutes']);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 3);
        }

        if (spaceCounters)
        {
            row.push(spaceCounters.instances);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 1);
        }

        row.push(spaceServiceInstanceCounter || 0);

        if (spaceCounters)
        {
            row.push(Utilities.convertBytesToMega(spaceCounters.used_memory));
            row.push(Utilities.convertBytesToMega(spaceCounters.used_disk));
            row.push(spaceCounters.used_cpu * 100);
            row.push(spaceCounters.reserved_memory);
            row.push(spaceCounters.reserved_disk);
            row.push(spaceCounters.total);
            row.push(spaceCounters[Constants.STATUS__STARTED] || 0);
            row.push(spaceCounters[Constants.STATUS__STOPPED] || 0);
            row.push(spaceCounters[Constants.STATUS__PENDING] || 0);
            row.push(spaceCounters[Constants.STATUS__STAGED]  || 0);
            row.push(spaceCounters[Constants.STATUS__FAILED]  || 0);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 11);
        }

        row.push({
                     "space": space,
                     "organization": organization
                 });

        tableData.push(row);
    }

    return tableData;
};

SpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(21, true);
};

SpacesTab.prototype.showDetails = function(table, target, row)
{
    var space        = target.space;
    var organization = target.organization;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(space.name), space, true);

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

    this.addPropertyRow(table, "Created", Format.formatDate(space.created_at));
    Utilities.hitchWhenHavingValue(this, table, this.addPropertyRow, "Updated", Format.formatDate, space.updated_at);

    var developersLink = document.createElement("a");
    $(developersLink).attr("href", "");
    $(developersLink).addClass("tableLink");
    $(developersLink).html(Format.formatNumber(row[4]));
    $(developersLink).click(function()
    {
        AdminUI.showDevelopers(Format.formatString(row[1]));

        return false;
    });
    this.addRow(table, "Developers", developersLink);

    var routesLink = document.createElement("a");
    $(routesLink).attr("href", "");
    $(routesLink).addClass("tableLink");
    $(routesLink).html(Format.formatNumber(row[5]));
    $(routesLink).click(function()
    {
        AdminUI.showRoutes(Format.formatString(row[1]));

        return false;
    });
    this.addRow(table, "Total Routes", routesLink);

    this.addPropertyRow(table, "Used Routes",   Format.formatNumber(row[6]));
    this.addPropertyRow(table, "Unused Routes", Format.formatNumber(row[7]));

    var instancesLink = document.createElement("a");
    $(instancesLink).attr("href", "");
    $(instancesLink).addClass("tableLink");
    $(instancesLink).html(Format.formatNumber(row[8]));
    $(instancesLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(row[1]));

        return false;
    });
    this.addRow(table, "Instances Used", instancesLink);

    var servicesLink = document.createElement("a");
    $(servicesLink).attr("href", "");
    $(servicesLink).addClass("tableLink");
    $(servicesLink).html(Format.formatNumber(row[9]));
    $(servicesLink).click(function()
    {
        AdminUI.showServiceInstances(Format.formatString(row[1]));

        return false;
    });
    this.addRow(table, "Services Used", servicesLink);

    this.addPropertyRow(table, "Memory Used",     Format.formatNumber(row[10]));
    this.addPropertyRow(table, "Disk Used",       Format.formatNumber(row[11]));
    this.addPropertyRow(table, "CPU Used",        Format.formatNumber(row[12]));
    this.addPropertyRow(table, "Memory Reserved", Format.formatNumber(row[13]));
    this.addPropertyRow(table, "Disk Reserved",   Format.formatNumber(row[14]));

    var appsLink = document.createElement("a");
    $(appsLink).attr("href", "");
    $(appsLink).addClass("tableLink");
    $(appsLink).html(Format.formatNumber(row[15]));
    $(appsLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(row[1]));

        return false;
    });
    this.addRow(table, "Total Apps", appsLink);

    this.addPropertyRow(table, "Started Apps",    Format.formatNumber(row[16]));
    this.addPropertyRow(table, "Stopped Apps",    Format.formatNumber(row[17]));
    this.addPropertyRow(table, "Pending Apps",    Format.formatNumber(row[18]));
    this.addPropertyRow(table, "Staged Apps",     Format.formatNumber(row[19]));
    this.addPropertyRow(table, "Failed Apps",     Format.formatNumber(row[20]));
};

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
    var deasDeferred             = Data.get(Constants.URL__DEAS,              false);
    var routesDeferred           = Data.get(Constants.URL__ROUTES,            false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);
    
    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred, routesDeferred, serviceInstancesDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        for (var index = 0; index < tableData.length; index++)
        {
            var row = tableData[index];

            if (row[1] == target)
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
};

SpacesTab.prototype.showSpaces = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      false);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            false);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, false);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     false);
    var deasDeferred             = Data.get(Constants.URL__DEAS,              false);
    var routesDeferred           = Data.get(Constants.URL__ROUTES,            false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);
    
    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred, routesDeferred, serviceInstancesDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        this.table.fnFilter(filter);

        this.show();
    },
    this));
};

