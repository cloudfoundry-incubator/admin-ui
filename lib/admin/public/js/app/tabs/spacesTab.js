
function SpacesTab(id)
{
    Tab.call(this, id, Constants.URL__SPACES_VIEW_MODEL);
}

SpacesTab.prototype = new Tab();

SpacesTab.prototype.constructor = SpacesTab;

SpacesTab.prototype.getInitialSort = function()
{
    return [[4, "desc"]];
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
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Roles",
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

SpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(21, true);
};

SpacesTab.prototype.showDetails = function(table, objects, row)
{
    var space        = objects.space;
    var organization = objects.organization;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(space.name), objects, true);

    if (organization != null)
    {
        var organizationLink = document.createElement("a");
        $(organizationLink).attr("href", "");
        $(organizationLink).addClass("tableLink");
        $(organizationLink).html(Format.formatStringCleansed(organization.name));
        $(organizationLink).click(function()
        {
            AdminUI.showOrganizations(organization.name);

            return false;
        });
        this.addRow(table, "Organization", organizationLink);
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(space.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, space.updated_at);

    if (row[4] != null)
    {
        var rolesLink = document.createElement("a");
        $(rolesLink).attr("href", "");
        $(rolesLink).addClass("tableLink");
        $(rolesLink).html(Format.formatNumber(row[4]));
        $(rolesLink).click(function()
        {
            AdminUI.showSpaceRoles(Format.formatString(row[1]));
    
            return false;
        });
        this.addRow(table, "Roles", rolesLink);
    }

    if (row[5] != null)
    {
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
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[6]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[7]);

    if (row[8] != null)
    {
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
    }

    if (row[9] != null)
    {
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
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used",     Format.formatNumber, row[10]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",       Format.formatNumber, row[11]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",        Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[14]);

    if (row[15] != null)
    {
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
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps", Format.formatNumber, row[19]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps", Format.formatNumber, row[20]);
};
