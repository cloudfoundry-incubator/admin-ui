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
                   "mRender":   function(value, type, item)
                   {
                       var name = item[1];
                       if (item[3] != null)
                       {
                           name += "." + item[3];
                       }
                       
                       return "<input type='checkbox' name='" + escape(name) + "' value='" + value + "' onclick='RoutesTab.prototype.checkboxClickHandler(event)'></input>";
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
            AdminUI.showDomains(domain.guid);
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

    if (space != null)
    {
        var spaceLink = document.createElement("a");
        $(spaceLink).attr("href", "");
        $(spaceLink).addClass("tableLink");
        $(spaceLink).html(Format.formatStringCleansed(space.name));
        $(spaceLink).click(function()
        {
            AdminUI.showSpaces(space.guid);

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
            AdminUI.showOrganizations(organization.guid);
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
                                                                          type:      "DELETE",
                                                                          url:       Constants.URL__ROUTES + "/" + route.guid,
                                                                          // Need route host inside the fail method
                                                                          routeHost: route.host
                                                                      });
                                                
                                                deferred.fail(function(xhr, status, error)
                                                {
                                                    errorRoutes.push({
                                                                         label: this.routeHost,
                                                                         xhr:   xhr
                                                                     });
                                                });
                                                
                                                deferred.always(function(xhr, status, error)
                                                {
                                                    processed++;
                                                    
                                                    if (processed == routes.length)
                                                    {
                                                        if (errorRoutes.length > 0)
                                                        {
                                                            AdminUI.showModalDialogErrorTable(errorRoutes);
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
        var checkedRow = checkedRows[checkedIndex];
        
        routes.push({
                        host: unescape(checkedRow.name),
                        guid: checkedRow.value
                    });
    }

    return routes;
};
