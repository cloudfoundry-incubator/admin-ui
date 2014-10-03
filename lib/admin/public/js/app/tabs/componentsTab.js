
function ComponentsTab(id)
{
    Tab.call(this, id, Constants.URL__COMPONENTS_VIEW_MODEL);
}

ComponentsTab.prototype = new Tab();

ComponentsTab.prototype.constructor = ComponentsTab;

ComponentsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

ComponentsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Name",
                   "sWidth":  "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Type",
                   "sWidth":  "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Index",
                   "sWidth":  "80px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "State",
                   "sWidth":  "80px",
                   "mRender": Format.formatStatus
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "170px",
                   "mRender": Format.formatString
               }
           ];
};

ComponentsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Remove OFFLINE", 
                   click: AdminUI.removeAllItemsConfirmation
               }
           ];
};

ComponentsTab.prototype.clickHandler = function()
{
    this.itemClicked(5, -1);
};

ComponentsTab.prototype.showDetails = function(table, component, row)
{
    this.addPropertyRow(table, "Name", component.name, true);
    this.addPropertyRow(table, "Type", component.data.type);
    this.addRowIfValue(this.addPropertyRow, table, "Index", Format.formatNumber, component.data.index);
    this.addRowIfValue(this.addPropertyRow, table, "Started", Format.formatDateString, component.data.start);
    this.addLinkRow(table, "URI", component);
    this.addStateRow(table, "State", row[3]);
};
