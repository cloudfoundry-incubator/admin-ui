
function ClientsTab(id)
{
    Tab.call(this, id, Constants.URL__CLIENTS_VIEW_MODEL);
}

ClientsTab.prototype = new Tab();

ClientsTab.prototype.constructor = ClientsTab;

ClientsTab.prototype.getInitialSort = function()
{
    return [[0, "asc"]];
};

ClientsTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle":  "Identifier",
                   "sWidth":  "300px",
                   "mRender": Format.formatUserString
               },
               {
                   "sTitle":  "Scopes",
                   "sWidth":  "200px",
                   "mRender": Format.formatClientStrings
               },
               {
                   "sTitle":  "Authorized Grant Types",
                   "sWidth":  "200px",
                   "mRender": Format.formatClientStrings
               },
               {
                   "sTitle":  "Redirect URI's",
                   "sWidth":  "200px",
                   "mRender": Format.formatClientStrings
               },
               {
                   "sTitle":  "Authorities",
                   "sWidth":  "200px",
                   "mRender": Format.formatClientStrings
               },
               {
                   "sTitle":  "Auto Approve",
                   "sWidth":  "200px",
                   "mRender": Format.formatBoolean
               },
               {
                   "sTitle":  "Events",
                   "sWidth":  "70px",
                   "sClass":  "cellRightAlign",
                   "mRender": Format.formatNumber
               },
               {
                   "sTitle":  "Service Broker",
                   "sWidth":  "200px",
                   "mRender": Format.formatServiceString
               },
           ];
};

ClientsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

ClientsTab.prototype.showDetails = function(table, objects, row)
{
    var client        = objects.client;
    var serviceBroker = objects.service_broker;
    
    this.addJSONDetailsLinkRow(table, "Identifier", Format.formatString(client.client_id), objects, true);
    this.showDetailsArray(table, row[1], "Scope");
    this.showDetailsArray(table, row[2], "Authorized Grant Type");
    this.showDetailsArray(table, row[3], "Redirect URI");
    this.showDetailsArray(table, row[4], "Authority");
    this.addRowIfValue(this.addPropertyRow, table, "Auto Approve", Format.formatBoolean, row[5]);
    
    if (row[6] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[6]), client.client_id, AdminUI.showEvents);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Additional Information", Format.formatStringCleansed, client.additional_information);
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
    }
};

ClientsTab.prototype.showDetailsArray = function(table, array, label)
{
    if (array != null)
    {
        for (var index = 0; index < array.length; index++)
        {
            var field = array[index];
            this.addPropertyRow(table, label, Format.formatString(field)); 
        }
    }
};
