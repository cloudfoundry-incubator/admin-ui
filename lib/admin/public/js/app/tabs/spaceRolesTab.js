
function SpaceRolesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SPACE_ROLES, Constants.URL__SPACE_ROLES_VIEW_MODEL);
}

SpaceRolesTab.prototype = new Tab();

SpaceRolesTab.prototype.constructor = SpaceRolesTab;

SpaceRolesTab.prototype.getColumns = function()
{
    return [
               {
                   "title":     Tab.prototype.formatCheckboxHeader(this.id),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       var name = "";
                       if (item[3] != null)
                       {
                           name += item[3];
                       }
                       else
                       {
                           name += item[1];
                       }
                       name += "/" + item[6] + "/" + item[4];
                       
                       return this.formatCheckbox(name, value);
                   },
                   this),
               },
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatSpaceName
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Target",
                   "width":  "200px",
                   "render": Format.formatTarget
               },
               {
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Role",
                   "width":  "200px",
                   "render": Format.formatString
               }        
           ];
};

SpaceRolesTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected space roles?",
                                          "Delete",
                                          "Deleting Space Roles",
                                          Constants.URL__SPACES,
                                          "");
                   },
                   this)
               }
           ];
};

SpaceRolesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

SpaceRolesTab.prototype.showDetails = function(table, objects, row)
{
    var organization = objects.organization;
    var space        = objects.space;
    var user_uaa     = objects.user_uaa;
    
    var spaceLink = this.createFilterLink(Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    var details = document.createElement("div");
    $(details).append(spaceLink);
    $(details).append(this.createJSONDetailsLink(objects));
    
    this.addRow(table, "Space", details, true);
    
    this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    
    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }
    
    this.addFilterRow(table, "User", Format.formatStringCleansed(user_uaa.username), user_uaa.id, AdminUI.showUsers);
    this.addPropertyRow(table, "User GUID", Format.formatString(user_uaa.id));
    this.addPropertyRow(table, "Role", Format.formatString(row[6]));
};
