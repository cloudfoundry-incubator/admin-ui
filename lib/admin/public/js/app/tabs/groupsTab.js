
function GroupsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__GROUPS, Constants.URL__GROUPS_VIEW_MODEL);
}

GroupsTab.prototype = new Tab();

GroupsTab.prototype.constructor = GroupsTab;

GroupsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"]];
};

GroupsTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[2], value);
                                      },
                                      this)
               },
               {
                   title:  "Identity Zone",
                   width:  "300px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "Name",
                   width:  "300px",
                   render: Format.formatGroupString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:     "Version",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Members",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

GroupsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected groups?",
                                                         "Delete",
                                                         "Deleting Groups",
                                                         Constants.URL__GROUPS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

GroupsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

GroupsTab.prototype.showDetails = function(table, objects, row)
{
    var group        = objects.group;
    var identityZone = objects.identity_zone;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(group.displayname), objects, first);
    this.addPropertyRow(table, "GUID", Format.formatString(group.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(group.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, group.lastmodified);
    this.addPropertyRow(table, "Version", Format.formatNumber(group.version));
    this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, group.description);
    this.addFilterRowIfValue(table, "Members", Format.formatNumber, row[7], group.id, AdminUI.showGroupMembers);
};
