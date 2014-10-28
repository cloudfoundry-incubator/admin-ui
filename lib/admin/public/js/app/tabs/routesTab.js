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
    return [[1, "asc"]];
};

RoutesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type)
                   {
                       return "<input type='checkbox' value='" + value + "' onclick='RoutesTab.prototype.checkboxClickHandler(event)'></input>";
                   }
               },
               {
                   "sTitle":  "Host",
                   "sWidth":  "200px",
                   "mRender": Format.formatHostName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Domain",
                   "sWidth":  "200px",
                   "mRender": Format.formatDomainName
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
                       this.deleteRoutes();
                   }, 
                   this)
               }
           ];
};

RoutesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

RoutesTab.prototype.showDetails = function(table, objects, row)
{
    var domain       = objects.domain;
    var route        = objects.route;
    var organization = objects.organization;
    var space        = objects.space;

    this.addJSONDetailsLinkRow(table, "Host", Format.formatString(row[1]), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(route.guid));
    
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

    this.addPropertyRow(table, "Created", Format.formatDateString(row[4]));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, route.updated_at);

    if (row[7] != null)
    {
        var appsLink = document.createElement("a");
        $(appsLink).attr("href", "");
        $(appsLink).addClass("tableLink");
        $(appsLink).html(Format.formatNumber(row[7].length));
        $(appsLink).click(function()
        {
            AdminUI.showApplications(Format.formatString(row[1] + "." + row[3]));

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

RoutesTab.prototype.deleteRoutes = function()
{
    var routes = this.getSelectedRoutes();

    if (!routes || routes.length == 0)
    {
        return;
    }

    AdminUI.showModalDialogConfirmation("Are you sure you want to delete the selected routes?",
                                        "Delete",
                                        function()
                                        {
                                            var processed = 0;
                                            
                                            var errorRoutes = [];
                                        
                                            AdminUI.showModalDialogProgress("Deleting Routes");
                                        
                                            for (var routeIndex = 0; routeIndex < routes.length; routeIndex++)
                                            {
                                                var route = routes[routeIndex];
                                                
                                                var deferred = $.ajax({
                                                                          type: "DELETE",
                                                                          url:  Constants.URL__ROUTES + "/" + route
                                                                      });
                                                
                                                deferred.fail(function(xhr, status, error)
                                                {
                                                    errorRoutes.push(route);
                                                });
                                                
                                                deferred.always(function(xhr, status, error)
                                                {
                                                    processed++;
                                                    
                                                    if (processed == routes.length)
                                                    {
                                                        if (errorRoutes.length > 0)
                                                        {
                                                            var errorDetail = "Error deleting the following routes:<br/>";
                                                            
                                                            for (var errorIndex = 0; errorIndex < errorRoutes.length; errorIndex++)
                                                            {
                                                                var errorRoute = errorRoutes[errorIndex];
                                                                
                                                                errorDetail += "<br/>" + errorRoute; 
                                                            }
                                                            
                                                            AdminUI.showModalDialogError(errorDetail);
                                                        }
                                                        else
                                                        {
                                                            AdminUI.showModalDialogSuccess();
                                                        }
                                                
                                                        AdminUI.refresh();
                                                    }
                                                });
                                            }
                                        });
};

RoutesTab.prototype.getSelectedRoutes = function()
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var routes = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        routes.push(checkedRows[checkedIndex].value);
    }

    return routes;
};
