
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
                   "title":  "Name",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Type",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":     "Index",
                   "width":     "80px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "State",
                   "width":  "80px",
                   "render": Format.formatStatus
               },
               {
                   "title":  "Started",
                   "width":  "170px",
                   "render": Format.formatString
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
    this.itemClicked(-1, 0);
};

ComponentsTab.prototype.showDetails = function(table, component, row)
{
    this.addPropertyRow(table, "Name", component.name, true);
    this.addPropertyRow(table, "Type", component.type);
    this.addPropertyRow(table, "Index", Format.formatNumber(component.index));
    this.addRowIfValue(this.addPropertyRow, table, "Started", Format.formatDateString, component.data.start);
    this.addLinkRow(table, "URI", component);
    this.addStateRow(table, "State", row[3]);
};
