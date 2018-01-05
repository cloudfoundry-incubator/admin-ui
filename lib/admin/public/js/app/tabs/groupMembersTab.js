
function GroupMembersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__GROUP_MEMBERS, Constants.URL__GROUP_MEMBERS_VIEW_MODEL);
}

GroupMembersTab.prototype = new Tab();

GroupMembersTab.prototype.constructor = GroupMembersTab;

GroupMembersTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var name = item[1] + "/" + item[3];

                                          return this.formatCheckbox(this.id, name, value);
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
                   width:  "200px",
                   render: Format.formatGroupString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatUserString
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
               }
           ];
};

GroupMembersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Remove",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to remove the selected group members?",
                                                         "Remove",
                                                         "Removing Group Members",
                                                         Constants.URL__GROUPS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

GroupMembersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

GroupMembersTab.prototype.showDetails = function(table, objects, row)
{
    var group           = objects.group;
    var groupMembership = objects.group_membership;
    var identityZone    = objects.identity_zone;
    var user            = objects.user_uaa;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    var groupLink = this.createFilterLink(Format.formatStringCleansed(group.displayname), group.id, AdminUI.showGroups);
    var details = document.createElement("div");
    $(details).append(groupLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Group", details, first);

    this.addPropertyRow(table, "Group GUID", Format.formatString(group.id));
    this.addFilterRow(table, "User", Format.formatStringCleansed(user.username), user.id, AdminUI.showUsers);
    this.addPropertyRow(table, "User GUID", Format.formatString(user.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(groupMembership.added));
};
