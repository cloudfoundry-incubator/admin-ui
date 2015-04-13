function UsersTab(id)
{
    Tab.call(this, id, Constants.URL__USERS_VIEW_MODEL);
}

UsersTab.prototype = new Tab();

UsersTab.prototype.constructor = UsersTab;

UsersTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

UsersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Username",
                   "sWidth": "200px",
                   "mRender": Format.formatUserString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
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
                   "sTitle":  "Email",
                   "sWidth":  "200px",
                   "mRender": Format.formatUserString
               },
               {
                   "sTitle":  "Family Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatUserString
               },
               {
                   "sTitle":  "Given Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatUserString
               },
               {
                   "sTitle":  "Active",
                   "sWidth":  "70px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Version",
                   "sWidth":  "100px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Groups",
                   "sWidth":  "200px",
                   "mRender": Format.formatGroups
               },
               {
                   "sTitle":  "Events",
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
                   "sTitle":  "Auditor",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender" : Format.formatNumber
               },
               {
                   "sTitle":  "Billing Manager",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Manager",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "User",
                   "sWidth":  "80px",
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
                   "sTitle":  "Auditor",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Developer",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Manager",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               }
           ];
};

UsersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

UsersTab.prototype.showDetails = function(table, objects, row)
{
    var user_uaa = objects.user_uaa;
    var groups   = objects.groups; 
    
    this.addJSONDetailsLinkRow(table, "Username", Format.formatString(user_uaa.username), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(user_uaa.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(user_uaa.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, user_uaa.lastmodified);
    
    var email = "mailto:" + Format.formatString(user_uaa.email);
    var emailLink = document.createElement("a");
    $(emailLink).attr("target", "_blank");
    $(emailLink).attr("href", email);
    $(emailLink).addClass("tableLink");
    $(emailLink).html(email);

    this.addRow(table, "Email", emailLink, false);
    
    this.addRowIfValue(this.addPropertyRow, table, "Family Name", Format.formatString, user_uaa.familyname);
    this.addRowIfValue(this.addPropertyRow, table, "Given Name", Format.formatString, user_uaa.givenname);
    this.addRowIfValue(this.addPropertyRow, table, "Active", Format.formatString, user_uaa.active);
    this.addPropertyRow(table, "Version", Format.formatNumber(user_uaa.version));

    if (groups != null)
    {
        for (var groupIndex = 0; groupIndex < groups.length; groupIndex++)
        {
            this.addPropertyRow(table, "Group", Format.formatString(groups[groupIndex]));
        }
    }

    if (row[10] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[10]), user_uaa.id, AdminUI.showEvents);
    }
    
    if (row[11] != null)
    {
        this.addFilterRow(table, "Organization Total Roles", Format.formatNumber(row[11]), user_uaa.id, AdminUI.showOrganizationRoles);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Organization Auditor Roles", Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Billing Manager Roles", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Manager Roles", Format.formatNumber, row[14]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization User Roles", Format.formatNumber, row[15]);
    
    if (row[16] != null)
    {
        this.addFilterRow(table, "Space Total Roles", Format.formatNumber(row[16]), user_uaa.id, AdminUI.showSpaceRoles);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Space Auditor Roles", Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Developer Roles", Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Manager Roles", Format.formatNumber, row[19]);
};
