
function EnvironmentGroupsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ENVIRONMENT_GROUPS, Constants.URL__ENVIRONMENT_GROUPS_VIEW_MODEL);
}

EnvironmentGroupsTab.prototype = new Tab();

EnvironmentGroupsTab.prototype.constructor = EnvironmentGroupsTab;

EnvironmentGroupsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.environmentGroupsVariablesTable = Table.createTable("EnvironmentGroupsVariables", this.getEnvironmentGroupsVariablesColumns(), [[0, "asc"]], null, null, Constants.FILENAME__ENVIRONMENT_GROUP_VARIABLES, null, null);
};

EnvironmentGroupsTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

EnvironmentGroupsTab.prototype.getColumns = function()
{
    return [
               {
                   title:  "Name",
                   width:  "300px",
                   render: Format.formatEnvironmentGroupName
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
               }
           ];
};

EnvironmentGroupsTab.prototype.getEnvironmentGroupsVariablesColumns = function()
{
    return [
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

EnvironmentGroupsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#EnvironmentGroupsVariablesTableContainer").hide();
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
        var variableFound = false;

        var environmentGroupsVariablesTableData = [];

        for (var key in variables)
        {
            variableFound = true;

            var value = variables[key];

            var environmentGroupVariableRow = [];

            environmentGroupVariableRow.push(key);
            environmentGroupVariableRow.push(JSON.stringify(value));

            environmentGroupsVariablesTableData.push(environmentGroupVariableRow);
        }

        if (variableFound)
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#EnvironmentGroupsVariablesTableContainer").show();

            this.environmentGroupsVariablesTable.api().clear().rows.add(environmentGroupsVariablesTableData).draw();
        }
    }
};
