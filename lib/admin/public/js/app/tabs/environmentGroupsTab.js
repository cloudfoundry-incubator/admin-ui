
function EnvironmentGroupsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ENVIRONMENT_GROUPS, Constants.URL__ENVIRONMENT_GROUPS_VIEW_MODEL);
}

EnvironmentGroupsTab.prototype = new Tab();

EnvironmentGroupsTab.prototype.constructor = EnvironmentGroupsTab;

EnvironmentGroupsTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

EnvironmentGroupsTab.prototype.getColumns = function()
{
    return [
               {
                   "title":  "Name",
                   "width":  "300px",
                   "render": Format.formatEnvironmentGroupName
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
               }
           ];
};

EnvironmentGroupsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

EnvironmentGroupsTab.prototype.showDetails = function(table, environmentGroup, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(environmentGroup.name), environmentGroup, true);
    this.addPropertyRow(table, "GUID", Format.formatString(environmentGroup.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(environmentGroup.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, environmentGroup.updated_at);

    var variables = environmentGroup.variables;

    if (variables != null)
    {
        for (var key in variables)
        {
            var value = variables[key];
            this.addPropertyRow(table, Format.formatStringCleansed('Variable "' + key + '"'), Format.formatString(JSON.stringify(value)));
        }
    }
};
