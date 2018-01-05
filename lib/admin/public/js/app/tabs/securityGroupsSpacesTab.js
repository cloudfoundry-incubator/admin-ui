
function SecurityGroupsSpacesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SECURITY_GROUPS_SPACES, Constants.URL__SECURITY_GROUPS_SPACES_VIEW_MODEL);
}

SecurityGroupsSpacesTab.prototype = new Tab();

SecurityGroupsSpacesTab.prototype.constructor = SecurityGroupsSpacesTab;

SecurityGroupsSpacesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var name = item[1] + "/";
                                          if (item[9] != null)
                                          {
                                              name += item[9];
                                          }
                                          else
                                          {
                                              name += item[5];
                                          }

                                          return this.formatCheckbox(this.id, name, value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatSecurityGroupString
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
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatSpaceName
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
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               },
           ];
};

SecurityGroupsSpacesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected security groups spaces?",
                                                         "Delete",
                                                         "Deleting Security Groups Spaces",
                                                         Constants.URL__SECURITY_GROUPS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

SecurityGroupsSpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

SecurityGroupsSpacesTab.prototype.showDetails = function(table, objects, row)
{
    var organization  = objects.organization;
    var securityGroup = objects.security_group;
    var space         = objects.space;

    var securityGroupLink = this.createFilterLink(Format.formatStringCleansed(securityGroup.name), securityGroup.guid, AdminUI.showSecurityGroups);
    var details = document.createElement("div");
    $(details).append(securityGroupLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Security Group", details, true);
    this.addPropertyRow(table, "Security Group GUID", Format.formatString(securityGroup.guid));
    this.addPropertyRow(table, "Security Group Created", Format.formatDateString(securityGroup.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Security Group Updated", Format.formatDateString, securityGroup.updated_at);
    this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    this.addPropertyRow(table, "Space Created", Format.formatDateString(space.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Space Updated", Format.formatDateString, space.updated_at);

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }
};
