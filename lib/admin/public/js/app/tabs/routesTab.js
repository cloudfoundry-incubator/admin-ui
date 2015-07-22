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
                   "sTitle":    Tab.prototype.formatCheckboxHeader(this.id),
                   "sWidth":    "2px",
                   "bSortable": false,
                   "mRender":   $.proxy(function(value, type, item)
                   {
                       var name = item[1];
                       if (item[4] != null)
                       {
                           if (name.length > 0)
                           {
                               name += ".";
                           }
                           
                           name += item[4];
                       }
                       
                       if (item[2] != null)
                       {
                           name += item[2];
                       }
                       
                       return this.formatCheckbox(name, value);
                   },
                   this),
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
                   "sTitle":  "Applications",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Target",
                   "sWidth":  "200px",
                   "sClass":  "cellLeftAlign",
                   "mRender": Format.formatTarget
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

    if ((domain != null) && (row[7] != null))
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
        
        this.addFilterRow(table, "Applications", Format.formatNumber(row[7]), fqdn, AdminUI.showApplications);
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
