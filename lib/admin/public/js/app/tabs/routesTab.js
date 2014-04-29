function RoutesTab(id)
{
    this.url = Constants.URL__ROUTES;
    Tab.call(this, id);
}

RoutesTab.prototype = new Tab();

RoutesTab.prototype.constructor = RoutesTab;

RoutesTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

RoutesTab.prototype.initialize = function()
{
    this.table = Table.createTable(
        this.id,
        this.getColumns(),
        this.getInitialSort(),
        $.proxy(this.clickHandler, this),
            [
                {
                    text: "Delete",
                    click: $.proxy(function()
                    {
                        this.manageRoutes("DELETE");
                }   , this)
                }
            ]
    );
};

RoutesTab.prototype.getInitialSort = function()
{
    return [[1, "desc"]];
};

RoutesTab.prototype.refresh = function(reload)
{
    var routesDeferred        = Data.get(Constants.URL__ROUTES,        reload);
    var spacesDeferred        = Data.get(Constants.URL__SPACES,        reload);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS, reload);

    $.when(routesDeferred, spacesDeferred, organizationsDeferred).done($.proxy(function(routesResult, spacesResult, organizationsResult)
    {
        this.updateData([routesResult, spacesResult, organizationsResult]);
    },
    this));
};

RoutesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "&nbsp;",
                   "sWidth": "2px",
                   "sClass": "cellCenterAlign",
                   "bSortable": false,
                   "mRender": function(value, type)
                   {
                       return '<input type="checkbox" value="' + value + '" onclick="RoutesTab.prototype.checkboxClickHandler"></input>';
                   }
               },
               {
                   "sTitle":  "Host",
                   "sWidth":  "200px"
               },
               {
                   "sTitle":  "Domain",
                   "sWidth":  "200px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatDateNumber
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatDateNumber
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "180px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Application",
                   "sWidth":  "200px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatApplications
               }
           ];
};

RoutesTab.prototype.getTableData = function(results)
{
    var routes        = results[0].response.items;
    var spaces        = results[1].response.items;
    var organizations = results[2].response.items;

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

    for (var routeIndex in routes)
    {
        var route = routes[routeIndex];
        var row = [];

        row.push(route.guid);
        row.push(route.host);
        row.push(route.domain.entity.name);
        row.push(route.created_at);
        if (route.updated_at != null)
        {
            row.push(route.updated_at);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        var space = spaceMap[route.space_guid];
        var organization = (space == null) ? null : organizationMap[space.organization_guid];

        if (organization != null && space != null)
        {
            row.push(organization.name + '/' + space.name);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        if (route.apps.length > 0)
        {
            var appArray = [];
            for (var appIndex = 0;appIndex < route.apps.length;appIndex ++)
            {
                appArray.push(route.apps[appIndex].entity.name);
            }

            row.push(appArray);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }

        row.push({
                     "organization": organization,
                     "route"       : route,
                     "space"       : space
                 });

        tableData.push(row);
    }

    return tableData;
};

RoutesTab.prototype.clickHandler = function()
{
    var tableTools = TableTools.fnGetInstance("RoutesTable");

    var selected = tableTools.fnGetSelectedData();

    this.hideDetails();

    if (selected.length > 0)
    {
        $("#RoutesDetailsLabel").show();

        var containerDiv = $("#RoutesPropertiesContainer").get(0);

        var table = this.createPropertyTable(containerDiv);

        var row = selected[0];

        var objects = row[7];

        var route        = objects.route;
        var organization = objects.organization;
        var space        = objects.space;

        this.addJSONDetailsLinkRow(table, "Host", Format.formatString(row[1]), route, true);
        this.addPropertyRow(table, "Domain", Format.formatString(row[2]));

        this.addPropertyRow(table, "Created", Format.formatDateString(row[3]));
        if (route.updated_at)
        {
            this.addPropertyRow(table, "Updated",  Format.formatDateString(route.updated_at));
        }

        var appsLink = document.createElement("a");
        $(appsLink).attr("href", "");
        $(appsLink).addClass("tableLink");
        $(appsLink).html(Format.formatNumber(row[6].length));
        $(appsLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(row[1] + '.' + row[2]));

            return false;
        });

        this.addRow(table, "Applications", appsLink);

        if (space != null && organization != null)
        {
            var spaceLink = document.createElement("a");
            $(spaceLink).attr("href", "");
            $(spaceLink).addClass("tableLink");
            $(spaceLink).html(Format.formatString(space.name));
            $(spaceLink).click(function()
            {
                // Select based on org/space target since space name is not unique.
                AdminUI.showSpace(Format.formatString(organization.name + "/" + space.name));

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
    }
};

RoutesTab.prototype.showRoutes = function(filter)
{
    AdminUI.setTabSelected(this.id);

    this.hideDetails();

    var routesDeferred        = Data.get(Constants.URL__ROUTES,        false);
    var spacesDeferred        = Data.get(Constants.URL__SPACES,        false);
    var organizationsDeferred = Data.get(Constants.URL__ORGANIZATIONS, false);

    $.when(routesDeferred, spacesDeferred, organizationsDeferred).done($.proxy(function(routesResult, spacesResult, organizationsResult)
    {
        this.updateData([routesResult, spacesResult, organizationsResult]);

        this.table.fnFilter(filter);

        this.show();
    },
    this));
};

RoutesTab.prototype.manageRoutes = function(method)
{
    var routes = this.getSelectedRoutes();

    if (!routes || routes.length == 0)
    {
        return;
    }

    if (!confirm("Are you sure you want to delete the selected routes?"))
    {
        return;
    }

    AdminUI.showModalDialog({ "body": $('<label>"Deleting routes, please wait..."</label>') });

    var error_routes = [];

    for (var step = 0; step < routes.length; step ++)
    {
        var route = routes[step];
        var url = "/routes/" + route;
        $.ajax({
            type: method,
            async: false,
            url: url,
            contentType: "route/json; charset=utf-8",
            dataType: "json",
            success: function (data) {},
            error: function (msg)
            {
                error_routes.push(route);
            }
        });
    }

    AdminUI.closeModalDialog();

    if (error_routes.length > 0)
    {
        alert("Error deleting the following routes:\n" + error_routes);
    }
    else
    {
        alert("Routes successfully deleted.");
    }

    AdminUI.refresh();
};

RoutesTab.prototype.getSelectedRoutes = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        alert("Please select at least one row!");
        return null;
    }

    var routes = [];

    for (var step = 0; step < checkedRows.length; step ++)
    {
        routes.push(checkedRows[step].value);
    }

    return routes;
};
