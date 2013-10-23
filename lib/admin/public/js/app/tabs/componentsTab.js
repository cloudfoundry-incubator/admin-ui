
function ComponentsTab(id)
{
    this.url = Constants.URL__COMPONENTS;

    Tab.call(this, id);
}

ComponentsTab.prototype = new Tab();

ComponentsTab.prototype.constructor = ComponentsTab;

ComponentsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    $("#ComponentsRemoveAllButton").click(AdminUI.removeAllItemsConfirmation);
}

ComponentsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
}

ComponentsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px"
               },
               {
                   "sTitle":  "Type",
                   "sWidth":  "200px"
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               }
           ];
}

ComponentsTab.prototype.updateTableRow = function(row, component)
{
    row.push(component.name);
    row.push(component.data.type);
    row.push(component.connected ? Constants.STATUS__RUNNING : Constants.STATUS__OFFLINE);        
    row.push((component.data.start != null ? component.data.start : ""));
    row.push(component);
    row.push(component.uri);
}

ComponentsTab.prototype.clickHandler = function()
{
    this.itemClicked(4, true);
}

ComponentsTab.prototype.showDetails = function(table, component, row)
{
    this.addPropertyRow(table, "Name",    component.name, true);
    this.addPropertyRow(table, "Type",    component.data.type);
    this.addPropertyRow(table, "Started", Format.formatString(Format.formatDateString(component.data.start)));
    this.addLinkRow(table,     "URI",     component);
    this.addStateRow(table,    "State",   row[2]);
}


