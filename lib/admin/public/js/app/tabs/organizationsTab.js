
function OrganizationsTab(id)
{
    Tab.call(this, id);
}

OrganizationsTab.prototype = new Tab();

OrganizationsTab.prototype.constructor = OrganizationsTab;

OrganizationsTab.prototype.initialize = function()
{
    this.table = Table.createTable(
        this.id,
        this.getColumns(),
        this.getInitialSort(),
        $.proxy(this.clickHandler, this),
        [
            {
                text: "Set Quota",
                click: $.proxy(function()
                {
                    this.manageQuotas();
                }, this)
            }
        ]);
}

OrganizationsTab.prototype.getInitialSort = function()
{
    return [[4, "desc"]];
}

OrganizationsTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
}

OrganizationsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "&nbsp;",
                    "sWidth": "2px",
                   "sClass": "cellCenterAlign",
                   "bSortable": false,
                   "mRender": function(value, type)
                   {
                       return '<input type="checkbox" value="' + value + '" onclick="OrganizationsTab.prototype.checkboxClickHandler(event)"></input>';
                   }
               },
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
                   "sTitle":  "Updated",
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
                   "sTitle":  "Quota",
                   "sWidth":  "90px",
                   "mRender": Format.formatString
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

OrganizationsTab.prototype.refresh = function(reload)
{
    var applicationsDeferred     = Data.get(Constants.URL__APPLICATIONS,      reload);
    var spacesDeferred           = Data.get(Constants.URL__SPACES,            reload);
    var spacesDevelopersDeferred = Data.get(Constants.URL__SPACES_DEVELOPERS, reload);
    var organizationsDeferred    = Data.get(Constants.URL__ORGANIZATIONS,     reload);
    var deasDeferred             = Data.get(Constants.URL__DEAS,              reload);
    var routesDeferred           = Data.get(Constants.URL__ROUTES,            reload);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, reload);
    var quotasDeferred           = Data.get(Constants.URL__QUOTA_DEFINITIONS, reload);

    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred, routesDeferred, serviceInstancesDeferred, quotasDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult, quotasResult)
    {
        this.updateData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult, quotasResult], reload);
    },
    this));
};

OrganizationsTab.prototype.getTableData = function(results)
{
    var applications     = results[0].response.items;
    var spaces           = results[1].response.items;
    var developers       = results[2].response.items;
    var organizations    = results[3].response.items;
    var deas             = results[4].response.items;
    var routes           = results[5].response.items;
    var serviceInstances = results[6].response.items;
    var quotas           = results[7].response.items;

    var spaceMap = [];
    var organizationSpaceCounters = [];
    var organizationDeveloperCounters = [];
    var organizationServiceInstanceCounters = [];

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

    for (var serviceInstanceIndex in serviceInstances)
    {
        var serviceInstance = serviceInstances[serviceInstanceIndex];

        var space = spaceMap[serviceInstance.space_guid];

        if (space != null)
        {
            var organization_guid = space.organization_guid;

            if (organizationServiceInstanceCounters[organization_guid] == undefined)
            {
                organizationServiceInstanceCounters[organization_guid] = 0;
            }

            organizationServiceInstanceCounters[organization_guid]++;
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
                     "instances"       : 0
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

    var organizationRouteCountersMap = [];

    for (var routeIndex in routes)
    {
        var route = routes[routeIndex];
        var space = spaceMap[route.space_guid];

        if (space != null)
        {
            var organization_guid = space.organization_guid;

            var organizationRouteCounters = organizationRouteCountersMap[organization_guid];

            if (!organizationRouteCounters)
            {
                organizationRouteCounters = [];
                organizationRouteCountersMap[organization_guid] = organizationRouteCounters;
            }

            if (!organizationRouteCounters['totalRoutes'])
            {
                organizationRouteCounters['totalRoutes'] = 0;
            }

            if (!organizationRouteCounters['unusedRoutes'])
            {
                organizationRouteCounters['unusedRoutes'] = 0;
            }

            if (route.apps.length == 0)
            {
                organizationRouteCounters['unusedRoutes'] ++;
            }

            organizationRouteCounters['totalRoutes'] ++;
        }
    }

    var quotasMap = [];

    for (var quota_index = 0; quota_index < quotas.length; quota_index ++)
    {
        var quota = quotas[quota_index];
        quotasMap[quota.guid] = quota;
    }

    var tableData = [];

    for (var organizationIndex in organizations)
    {
        var organization                       = organizations[organizationIndex];
        var organizationDeveloperCounter       = organizationDeveloperCounters[organization.guid];
        var organizationSpaceCounter           = organizationSpaceCounters[organization.guid];
        var organizationServiceInstanceCounter = organizationServiceInstanceCounters[organization.guid];
        var organizationAppCounters            = organizationAppCountersMap[organization.guid];
        var organizationRouteCounters          = organizationRouteCountersMap[organization.guid];

        var row = [];

        row.push(organization.guid);

        row.push(organization.name);
        row.push(organization.status);
        row.push(organization.created_at);
        if (organization.updated_at != null)
        {
            row.push(organization.updated_at);
        }
        else 
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push(organizationSpaceCounter || 0);
        row.push(organizationDeveloperCounter || 0);

        var quota = quotasMap[organization.quota_definition_guid];

        if (quota)
        {
            row.push(quota.name);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        if (organizationRouteCounters)
        {
            row.push(organizationRouteCounters['totalRoutes']);
            row.push(organizationRouteCounters['totalRoutes'] - organizationRouteCounters['unusedRoutes']);
            row.push(organizationRouteCounters['unusedRoutes']);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 3);
        }

        if (organizationAppCounters)
        {
            row.push(organizationAppCounters.instances);
        }
        else
        {
            Utilities.addZeroElementsToArray(row, 1);
        }

        row.push(organizationServiceInstanceCounter || 0);

        if (organizationAppCounters)
        {
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
            Utilities.addZeroElementsToArray(row, 11);
        }

        row.push(organization);

        tableData.push(row);
    }

    return tableData;
};

OrganizationsTab.prototype.clickHandler = function()
{
    this.itemClicked(24, true);
}

OrganizationsTab.prototype.showDetails = function(table, organization, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), organization, true);

    this.addPropertyRow(table, "Status",          Format.formatString(organization.status).toUpperCase());
    this.addPropertyRow(table, "Created",         Format.formatDate(organization.created_at));
    Utilities.hitchWhenHavingValue(this,          table,  this.addPropertyRow, "Updated", Format.formatDate, organization.updated_at);
    this.addPropertyRow(table, "Billing Enabled", Format.formatString(organization.billing_enabled));

    var spacesLink = document.createElement("a");
    $(spacesLink).attr("href", "");
    $(spacesLink).addClass("tableLink");
    $(spacesLink).html(Format.formatNumber(row[5]));
    $(spacesLink).click(function()
    {
        AdminUI.showSpaces(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Spaces", spacesLink);

    var developersLink = document.createElement("a");
    $(developersLink).attr("href", "");
    $(developersLink).addClass("tableLink");
    $(developersLink).html(Format.formatNumber(row[6]));
    $(developersLink).click(function()
    {
        AdminUI.showDevelopers(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Developers", developersLink);

    var quotaLink = document.createElement("a");
    $(quotaLink).attr("href", "");
    $(quotaLink).addClass("tableLink");
    $(quotaLink).html(Format.formatString(row[7]));
    $(quotaLink).click(function()
    {
        AdminUI.showQuota(row[7]);

        return false;
    });
    this.addRow(table, "Quota", quotaLink);

    var routesLink = document.createElement("a");
    $(routesLink).attr("href", "");
    $(routesLink).addClass("tableLink");
    $(routesLink).html(Format.formatNumber(row[8]));
    $(routesLink).click(function()
    {
        AdminUI.showRoutes(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Total Routes", routesLink);

    this.addPropertyRow(table, "Used Routes", Format.formatNumber(row[9]));
    this.addPropertyRow(table, "Unused Routes", Format.formatNumber(row[10]));

    var instancesLink = document.createElement("a");
    $(instancesLink).attr("href", "");
    $(instancesLink).addClass("tableLink");
    $(instancesLink).html(Format.formatNumber(row[11]));
    $(instancesLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Instances Used", instancesLink);

    var servicesLink = document.createElement("a");
    $(servicesLink).attr("href", "");
    $(servicesLink).addClass("tableLink");
    $(servicesLink).html(Format.formatNumber(row[12]));
    $(servicesLink).click(function()
    {
        AdminUI.showServiceInstances(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Services Used", servicesLink);

    this.addPropertyRow(table, "Memory Used",     Format.formatNumber(row[13]));
    this.addPropertyRow(table, "Disk Used",       Format.formatNumber(row[14]));
    this.addPropertyRow(table, "CPU Used",        Format.formatNumber(row[15]));
    this.addPropertyRow(table, "Memory Reserved", Format.formatNumber(row[16]));
    this.addPropertyRow(table, "Disk Reserved",   Format.formatNumber(row[17]));

    var appsLink = document.createElement("a");
    $(appsLink).attr("href", "");
    $(appsLink).addClass("tableLink");
    $(appsLink).html(Format.formatNumber(row[18]));
    $(appsLink).click(function()
    {
        AdminUI.showApplications(Format.formatString(organization.name) + "/");

        return false;
    });
    this.addRow(table, "Total Apps", appsLink);

    this.addPropertyRow(table, "Started Apps",    Format.formatNumber(row[19]));
    this.addPropertyRow(table, "Stopped Apps",    Format.formatNumber(row[20]));
    this.addPropertyRow(table, "Pending Apps",    Format.formatNumber(row[21]));
    this.addPropertyRow(table, "Staged Apps",     Format.formatNumber(row[22]));
    this.addPropertyRow(table, "Failed Apps",     Format.formatNumber(row[23]));
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
    var routesDeferred           = Data.get(Constants.URL__ROUTES,            false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);
    var quotasDeferred           = Data.get(Constants.URL__QUOTA_DEFINITIONS, false);

    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred, routesDeferred, serviceInstancesDeferred, quotasDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult, quotasResult)
    {
        var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult, quotasResult]);

        this.table.fnClearTable();
        this.table.fnAddData(tableData);

        for (var index = 0; index < tableData.length; index++)
        {
            var row = tableData[index];

            if (row[1] == organizationName)
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
};

OrganizationsTab.prototype.showOrganizations = function(filter)
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
    var quotasDeferred           = Data.get(Constants.URL__QUOTA_DEFINITIONS, false);

    $.when(applicationsDeferred, spacesDeferred, spacesDevelopersDeferred, organizationsDeferred, deasDeferred, routesDeferred, serviceInstancesDeferred, quotasDeferred).done($.proxy(function(applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult, quotasResult)
        {
            var tableData = this.getTableData([applicationsResult, spacesResult, spacesDevelopersResult, organizationsResult, deasResult, routesResult, serviceInstancesResult, quotasResult]);

            this.table.fnClearTable();
            this.table.fnAddData(tableData);

            this.table.fnFilter(filter);

            this.show();
        },
        this));
};

OrganizationsTab.prototype.manageQuotas = function()
{
    if (!this.getSelectedOrgs())
    {
        return;
    }

    var quotasDeferred = Data.get(Constants.URL__QUOTA_DEFINITIONS, false);

    $.when(quotasDeferred).done($.proxy(function(quotasResult)
    {
        var quotas = quotasResult.response.items;
        var dialogContentDiv = $('<div class="quota_management_div"></div>');
        dialogContentDiv.append($('<label>Select a qutoa: </label>'));

        var selector = $('<select id="quotaSelector"></select>');

        for (var step = 0; step < quotas.length; step ++)
        {
            var quota = quotas[step];
            selector.append($('<option value="' + quota.guid + '">' + quota.name + '</quota>'));
        }

        dialogContentDiv.append(selector);

        AdminUI.showModalDialog(
            {
                "body": dialogContentDiv,
                "title": "Set quota for organization",
                "height": 60,
                "buttons": [
                    {
                        "name": "Set",
                        "callback": $.proxy(function()
                        {
                            AdminUI.closeModalDialog();
                            this.setQuota($('#quotaSelector').val());
                        }, this)
                    },
                    {
                        "name": "Cancel",
                        "callback": function(){
                            AdminUI.closeModalDialog();
                        }
                    }
                ]
            });
    }, this));
}

OrganizationsTab.prototype.setQuota = function(quota_id)
{

    AdminUI.showModalDialog({ "body": $('<label>"Performing operation, please wait..."</label>') });

    var error_orgs = [];

    var orgs = this.getSelectedOrgs();

    for (var step = 0; step < orgs.length; step ++)
    {
        var org = orgs[step];

        var type = "PUT";
        var url = "/organizations/" + org;

        var successCallback = function(data){};
        var errorCallback = function(msg)
        {
            error_orgs.push(org);
        }

        this.sendSyncRequest(type, url, '{"quota_definition_guid":"' + quota_id + '"}', successCallback, errorCallback);
    }

    AdminUI.closeModalDialog();

    if (error_orgs.length > 0)
    {
        alert("Error handling the following organizations:\n" + error_orgs);
    }
    else
    {
        // Todos: we need to implement a polling backend service to get the latest app data in the future
        alert("The operation finished without error.\nPlease refresh the page later for the updated result.");
    }

    AdminUI.refresh();
}

OrganizationsTab.prototype.sendSyncRequest = function(type, url, body, successCallback, errorCallback)
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
}

OrganizationsTab.prototype.getSelectedOrgs = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        alert("Please select at least one row!");
        return null;
    }

    var orgs = [];

    for (var step = 0; step < checkedRows.length; step ++)
    {
        orgs.push(checkedRows[step].value);
    }

    return orgs;
}


