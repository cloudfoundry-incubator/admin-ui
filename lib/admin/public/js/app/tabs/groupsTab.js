function GroupsTab(id)
{
    Tab.call(this, id, Constants.URL__GROUPS_VIEW_MODEL);
}

GroupsTab.prototype = new Tab();

GroupsTab.prototype.constructor = GroupsTab;

GroupsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

GroupsTab.prototype.getColumns = function()
{
    return [
               {
                   "title":  "Identity Zone",
                   "width":  "300px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "Name",
                   "width":  "300px",
                   "render": Format.formatGroupString
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
                   "title":     "Version",
                   "width":     "100px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Members",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               }
           ];
};

GroupsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

GroupsTab.prototype.showDetails = function(table, objects, row)
{
    var group        = objects.group; 
    var identityZone = objects.identity_zone;
    
    var first = true;
    
    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        first = false;
    }
    
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(group.displayname), objects, first);
    this.addPropertyRow(table, "GUID", Format.formatString(group.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(group.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, group.lastmodified);
    this.addPropertyRow(table, "Version", Format.formatNumber(group.version));

    if (row[6] != null)
    {
        this.addFilterRow(table, "Members", Format.formatNumber(row[6]), group.displayname, AdminUI.showUsers);
    }
};
