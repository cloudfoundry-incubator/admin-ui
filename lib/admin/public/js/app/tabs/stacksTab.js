
function StacksTab(id)
{
    Tab.call(this, id, Constants.URL__STACKS_VIEW_MODEL);
}

StacksTab.prototype = new Tab();

StacksTab.prototype.constructor = StacksTab;

StacksTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

StacksTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatStackName
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
                   "sTitle":  "Applications",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Application Instances",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Description",
                   "sWidth":  "300px",
                   "mRender": Format.formatStringCleansed
               }
           ];
};

StacksTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

StacksTab.prototype.showDetails = function(table, stack, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(stack.name), stack, true);
    this.addPropertyRow(table, "GUID", Format.formatString(stack.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(stack.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, stack.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, stack.description);

    if (row[4] != null)
    {
        this.addFilterRow(table, "Applications", Format.formatNumber(row[4]), stack.name, AdminUI.showApplications);
    }
    
    if (row[5] != null)
    {
        this.addFilterRow(table, "Application Instances", Format.formatNumber(row[5]), stack.name, AdminUI.showApplicationInstances);
    }
};
