function RoutesTab(id)
{
    Tab.call(this, id, Constants.URL__ROUTES_VIEW_MODEL);
}

RoutesTab.prototype = new Tab();

RoutesTab.prototype.constructor = RoutesTab;

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
                       
                       return Tab.prototype.formatCheckbox(name, value);
                   }
               },
               {
                   "sTitle":  "Host",
                   "sWidth":  "200px",
                   "mRender": Format.formatRouteString
               },
               {
                   "sTitle":  "Path",
                   "sWidth":  "200px",
                   "mRender": Format.formatRouteString
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
                   "sTitle":  "Applications",
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
                       this.deleteChecked("Are you sure you want to delete the selected routes?",
                                          "Delete",
                                          "Deleting Routes",
                                          Constants.URL__ROUTES,
                                          "");
                   }, 
                   this)
               }
           ];
};

RoutesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

RoutesTab.prototype.showDetails = function(table, objects, row)
{
    var domain       = objects.domain;
    var organization = objects.organization;
    var route        = objects.route;
    var space        = objects.space;

    this.addRowIfValue(this.addPropertyRow, table, "Host", Format.formatString, route.host);
    this.addRowIfValue(this.addPropertyRow, table, "Path", Format.formatString, route.path);
    this.addJSONDetailsLinkRow(table, "GUID", Format.formatString(route.guid), objects, true);
    
    if (domain != null)
    {
        this.addFilterRow(table, "Domain", Format.formatStringCleansed(domain.name), domain.guid, AdminUI.showDomains);
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(route.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, route.updated_at);

    if (domain != null)
    {
        var fqdn = Format.formatString(domain.name);
        if (route.host.length > 0)
        {
            fqdn = Format.formatString(route.host) + "." + fqdn;
        }    
        
        if (route.path != null)
        {
            fqdn += Format.formatString(route.path);
        }
        
        this.addFilterRow(table, "Applications", Format.formatNumber(row[8].length), fqdn, AdminUI.showApplications);
    }

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }
};
