
function UsersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__USERS, Constants.URL__USERS_VIEW_MODEL);
}

UsersTab.prototype = new Tab();

UsersTab.prototype.constructor = UsersTab;

UsersTab.prototype.getInitialSort = function()
{
    return [[2, "asc"]];
};

UsersTab.prototype.getColumns = function()
{
    return [
               {
                   "title":     Tab.prototype.formatCheckboxHeader(this.id),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[2], value);
                   },
                   this),
               },
               {
                   "title":  "Identity Zone",
                   "width":  "300px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "Username",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Password Updated",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Email",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "Family Name",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "Given Name",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "Active",
                   "width":  "70px",
                   "render": Format.formatBoolean
               },
               {
                   "title":     "Version",
                   "width":     "100px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Groups",
                   "width":  "200px",
                   "render": Format.formatGroups
               },
               {
                   "title":     "Events",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Approvals",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Total",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Auditor",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Billing Manager",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Manager",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "User",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Total",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Auditor",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Developer",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Manager",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               }
           ];
};


UsersTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected users?",
                                          "Delete",
                                          "Deleting Users",
                                          Constants.URL__USERS,
                                          "");
                   },
                   this)
               }
           ];
};

UsersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

UsersTab.prototype.showDetails = function(table, objects, row)
{
    var groups       = objects.groups; 
    var identityZone = objects.identity_zone;
    var user         = objects.user_uaa;
    
    var first = true;
    
    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        first = false;
    }
    
    this.addJSONDetailsLinkRow(table, "Username", Format.formatString(user.username), objects, first);
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
            var group = groups[groupIndex];
            this.addFilterRow(table, "Group", Format.formatStringCleansed(group), group, AdminUI.showGroups);
        }
    }

    if (row[13] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[13]), user.id, AdminUI.showEvents);
    }
    
    if (row[14] != null)
    {
        this.addFilterRow(table, "Approvals", Format.formatNumber(row[14]), user.id, AdminUI.showApprovals);
    }
    
    if (row[15] != null)
    {
        this.addFilterRow(table, "Organization Total Roles", Format.formatNumber(row[15]), user.id, AdminUI.showOrganizationRoles);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Organization Auditor Roles", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Billing Manager Roles", Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Manager Roles", Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization User Roles", Format.formatNumber, row[19]);
    
    if (row[20] != null)
    {
        this.addFilterRow(table, "Space Total Roles", Format.formatNumber(row[20]), user.id, AdminUI.showSpaceRoles);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Space Auditor Roles", Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Developer Roles", Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Manager Roles", Format.formatNumber, row[23]);
};
