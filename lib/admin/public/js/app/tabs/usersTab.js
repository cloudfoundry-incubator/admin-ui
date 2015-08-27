function UsersTab(id)
{
    Tab.call(this, id, Constants.URL__USERS_VIEW_MODEL);
}

UsersTab.prototype = new Tab();

UsersTab.prototype.constructor = UsersTab;

UsersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

UsersTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Identity Zone",
                   "sWidth":  "300px",
                   "mRender": Format.formatIdentityString
               },
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
                   "sTitle":  "Password Updated",
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
                   "mRender": Format.formatBoolean
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
    this.itemClicked(-1, 2);
};

UsersTab.prototype.showDetails = function(table, objects, row)
{
    var groups       = objects.groups; 
    var identityZone = objects.identity_zone;
    var user         = objects.user_uaa;
    
    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones);
    }
    
    this.addJSONDetailsLinkRow(table, "Username", Format.formatString(user.username), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(user.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(user.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, user.lastmodified);
    this.addRowIfValue(this.addPropertyRow, table, "Password Updated", Format.formatDateString, user.passwd_lastmodified);
    
    var email = "mailto:" + Format.formatString(user.email);
    var emailLink = document.createElement("a");
    $(emailLink).attr("target", "_blank");
    $(emailLink).attr("href", email);
    $(emailLink).addClass("tableLink");
    $(emailLink).html(email);

    this.addRow(table, "Email", emailLink, false);
    
    this.addRowIfValue(this.addPropertyRow, table, "Family Name", Format.formatString, user.familyname);
    this.addRowIfValue(this.addPropertyRow, table, "Given Name", Format.formatString, user.givenname);
    this.addRowIfValue(this.addPropertyRow, table, "Active", Format.formatBoolean, user.active);
    this.addPropertyRow(table, "Version", Format.formatNumber(user.version));

    if (groups != null)
    {
        for (var groupIndex = 0; groupIndex < groups.length; groupIndex++)
        {
            this.addPropertyRow(table, "Group", Format.formatString(groups[groupIndex]));
        }
    }

    if (row[12] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[12]), user.id, AdminUI.showEvents);
    }
    
    if (row[13] != null)
    {
        this.addFilterRow(table, "Organization Total Roles", Format.formatNumber(row[13]), user.id, AdminUI.showOrganizationRoles);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Organization Auditor Roles", Format.formatNumber, row[14]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Billing Manager Roles", Format.formatNumber, row[15]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Manager Roles", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization User Roles", Format.formatNumber, row[17]);
    
    if (row[18] != null)
    {
        this.addFilterRow(table, "Space Total Roles", Format.formatNumber(row[18]), user.id, AdminUI.showSpaceRoles);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Space Auditor Roles", Format.formatNumber, row[19]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Developer Roles", Format.formatNumber, row[20]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Manager Roles", Format.formatNumber, row[21]);
};
