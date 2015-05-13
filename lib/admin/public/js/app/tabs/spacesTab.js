
function SpacesTab(id)
{
    Tab.call(this, id, Constants.URL__SPACES_VIEW_MODEL);
}

SpacesTab.prototype = new Tab();

SpacesTab.prototype.constructor = SpacesTab;

SpacesTab.prototype.getInitialSort = function()
{
    return [[3, "asc"]];
};

SpacesTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":    "&nbsp;",
                   "sWidth":    "2px",
                   "sClass":    "cellCenterAlign",
                   "bSortable": false,
                   "mRender":   function(value, type, item)
                   {
                       return Tab.prototype.formatCheckbox(item[1], value);
                   }
               },
               {
                   "sTitle": "Name",
                   "sWidth": "100px",
                   "mRender": Format.formatSpaceName
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sTitle":  "Events",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Events Target",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Roles",
                   "sWidth":  "90px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Space Quota",
                   "sWidth":  "90px",
                   "mRender": Format.formatQuotaName
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

SpacesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected spaces?",
                                          "Delete",
                                          "Deleting Spaces",
                                          Constants.URL__SPACES,
                                          "");
                   },
                   this)
               },
               {
                   text: "Delete Recursive",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected spaces and their contained applications, routes, service instances, service bindings and service keys?",
                                          "Delete Recursive",
                                          "Deleting Spaces and their Contents",
                                          Constants.URL__SPACES,
                                          "?recursive=true");
                   },
                   this)
               }
           ];
};

SpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

SpacesTab.prototype.showDetails = function(table, objects, row)
{
    var organization = objects.organization;
    var space        = objects.space;
    var spaceQuota   = objects.space_quota_definition;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(space.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(space.guid));

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(space.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, space.updated_at);

    if (row[6] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[6]), space.guid, AdminUI.showEvents);
    }
    
    if (row[7] != null)
    {
        this.addFilterRow(table, "Events Target", Format.formatNumber(row[7]), Format.formatString(row[3]), AdminUI.showEvents);
    }
    
    if (row[8] != null)
    {
        this.addFilterRow(table, "Roles", Format.formatNumber(row[8]), space.guid, AdminUI.showSpaceRoles);
    }

    if (spaceQuota != null)
    {
        this.addFilterRow(table, "Space Quota", Format.formatStringCleansed(spaceQuota.name), spaceQuota.guid, AdminUI.showSpaceQuotas);
    }
    
    if (row[10] != null)
    {
        this.addFilterRow(table, "Total Routes", Format.formatNumber(row[10]), Format.formatString(row[3]), AdminUI.showRoutes);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[11]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[12]);

    if (row[13] != null)
    {
        this.addFilterRow(table, "Instances Used", Format.formatNumber(row[13]), Format.formatString(row[3]), AdminUI.showApplicationInstances);
    }

    if (row[14] != null)
    {
        this.addFilterRow(table, "Services Used", Format.formatNumber(row[14]), Format.formatString(row[3]), AdminUI.showServiceInstances);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used",     Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",       Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",        Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[19]);

    if (row[20] != null)
    {
        this.addFilterRow(table, "Total Apps", Format.formatNumber(row[20]), Format.formatString(row[3]), AdminUI.showApplications);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[23]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps", Format.formatNumber, row[24]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps", Format.formatNumber, row[25]);
};
