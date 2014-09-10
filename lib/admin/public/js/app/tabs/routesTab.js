function RoutesTab(id)
{
    Tab.call(this, id, Constants.URL__ROUTES_VIEW_MODEL);
}

RoutesTab.prototype = new Tab();

RoutesTab.prototype.constructor = RoutesTab;

RoutesTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

RoutesTab.prototype.getInitialSort = function()
{
    return [[1, "desc"]];
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
                   "sWidth":  "200px"
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px"
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px"
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatTarget
               },
               {
                   "sTitle":  "Application",
                   "sWidth":  "200px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatApplications
               }
           ];
};

RoutesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.manageRoutes("DELETE");
                   }, 
                   this)
               }
           ];
};

RoutesTab.prototype.clickHandler = function()
{
    this.itemClicked(7, true);
};

RoutesTab.prototype.showDetails = function(table, objects, row)
{
    var domain       = objects.domain;
    var route        = objects.route;
    var organization = objects.organization;
    var space        = objects.space;

    this.addJSONDetailsLinkRow(table, "Host", Format.formatString(row[1]), objects, true);
    
    if (domain != null)
    {
        var domainLink = document.createElement("a");
        $(domainLink).attr("href", "");
        $(domainLink).addClass("tableLink");
        $(domainLink).html(Format.formatStringCleansed(domain.name));
        $(domainLink).click(function()
        {
            AdminUI.showDomains(Format.formatString(domain.name));
            return false;
        });

        this.addRow(table, "Domain", domainLink);
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(row[3]));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, route.updated_at);

    if (row[6] != null)
    {
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
    }

    if (space != null && organization != null)
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(space.name));
        $(spaceLink).click(function()
        {
            // Select based on org/space target since space name is not unique.
            AdminUI.showSpaces(Format.formatString(organization.name + "/" + space.name));

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
        var url = Constants.URL__ROUTES + "/" + route;
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
