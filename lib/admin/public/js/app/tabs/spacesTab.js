
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

SpacesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected spaces?",
                                          "Deleting Spaces",
                                          Constants.URL__SPACES);
                   },
                   this)
               },
           ];
};

SpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

SpacesTab.prototype.showDetails = function(table, objects, row)
{
    var space        = objects.space;
    var organization = objects.organization;

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
        this.addFilterRow(table, "Roles", Format.formatNumber(row[6]), space.guid, AdminUI.showSpaceRoles);
    }

    if (row[7] != null)
    {
        this.addFilterRow(table, "Total Routes", Format.formatNumber(row[7]), Format.formatString(row[3]), AdminUI.showRoutes);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[9]);

    if (row[10] != null)
    {
        this.addFilterRow(table, "Instances Used", Format.formatNumber(row[10]), Format.formatString(row[3]), AdminUI.showApplications);
    }

    if (row[11] != null)
    {
        this.addFilterRow(table, "Services Used", Format.formatNumber(row[11]), Format.formatString(row[3]), AdminUI.showServiceInstances);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used",     Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",       Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",        Format.formatNumber, row[14]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[16]);

    if (row[17] != null)
    {
        this.addFilterRow(table, "Total Apps", Format.formatNumber(row[17]), Format.formatString(row[3]), AdminUI.showApplications);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[19]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[20]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps", Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps", Format.formatNumber, row[22]);
};
