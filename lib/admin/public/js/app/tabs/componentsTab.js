
function ComponentsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__COMPONENTS, Constants.URL__COMPONENTS_VIEW_MODEL);
}

ComponentsTab.prototype = new Tab();

ComponentsTab.prototype.constructor = ComponentsTab;

ComponentsTab.prototype.getColumns = function()
{
    return [
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Type",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Index",
                   width:  "300px",
                   render: Format.formatString
               },
               {
                   title:  "Source",
                   width:  "80px",
                   render: Format.formatString
               },
               {
                   title:  "Metrics",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "80px",
                   render: function(value, type, item)
                           {
                               if (item[3] == "doppler")
                               {
                                   return Format.formatDopplerStatus(value, type, item);
                               }
                               else
                               {
                                   return Format.formatStatus(value, type, item);
                               }
                           }
               },
               {
                   title:  "Started",
                   width:  "170px",
                   render: Format.formatString
               }
           ];
};

ComponentsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Remove OFFLINE Doppler",
                   click: AdminUI.removeAllDopplerItemsConfirmation
               },
               {
                   text:  "Remove OFFLINE Varz",
                   click: AdminUI.removeAllVarzItemsConfirmation
               }
           ];
};

ComponentsTab.prototype.clickHandler = function()
{
    // This is using a non-visible column for the key
    this.itemClicked(-1, 7);
};

ComponentsTab.prototype.showDetails = function(table, objects, row)
{
    var dopplerComponent = objects.doppler_component;
    var varzComponent    = objects.varz_component;

    if (varzComponent != null)
    {
        this.addPropertyRow(table, "Name", varzComponent.name, true);
        this.addPropertyRow(table, "Type", varzComponent.type);
        this.addPropertyRow(table, "Index", Format.formatString(row[2]));
        this.addPropertyRow(table, "Source", Format.formatString(row[3]));
        this.addLinkRow(table, "URI", varzComponent);
        this.addStateRow(table, "State", row[5]);
        this.addRowIfValue(this.addPropertyRow, table, "Started", Format.formatDateString, varzComponent.data.start);
    }
    else if (dopplerComponent != null)
    {
        this.addJSONDetailsLinkRow(table, "Name", Format.formatString(row[0]), dopplerComponent, true);
        this.addPropertyRow(table, "Type", dopplerComponent.origin);
        this.addPropertyRow(table, "IP", Format.formatString(dopplerComponent.ip));
        this.addPropertyRow(table, "Index", Format.formatString(dopplerComponent.index));
        this.addPropertyRow(table, "Source", Format.formatString(row[3]));
        this.addPropertyRow(table, "Metrics", Format.formatDateString(row[4]));
        this.addStateRow(table, "State", row[5]);
    }
};
