
function ClientsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__CLIENTS, Constants.URL__CLIENTS_VIEW_MODEL);
}

ClientsTab.prototype = new Tab();

ClientsTab.prototype.constructor = ClientsTab;

ClientsTab.prototype.getInitialSort = function()
{
    return [[2, "asc"]];
};

ClientsTab.prototype.getColumns = function()
{
    return [
               {
                   "title":     Tab.prototype.formatCheckboxHeader(this.id),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[2], value);
                   },
                   this),
               },
               {
                   "title":  "Identity Zone",
                   "width":  "300px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "Identifier",
                   "width":  "300px",
                   "render": Format.formatUserString
               },
               {
                   "title":  "Scopes",
                   "width":  "200px",
                   "render": Format.formatClientStrings
               },
               {
                   "title":  "Authorized Grant Types",
                   "width":  "200px",
                   "render": Format.formatClientStrings
               },
               {
                   "title":  "Redirect URIs",
                   "width":  "200px",
                   "render": Format.formatClientStrings
               },
               {
                   "title":  "Authorities",
                   "width":  "200px",
                   "render": Format.formatClientStrings
               },
               {
                   "title":  "Auto Approve",
                   "width":  "200px",
                   "render": Format.formatClientStrings
               },
               {
                   "title":     "Events",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Service Broker",
                   "width":  "200px",
                   "render": Format.formatServiceString
               }
           ];
};

ClientsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected clients?",
                                          "Delete",
                                          "Deleting Clients",
                                          Constants.URL__CLIENTS,
                                          "");
                   },
                   this)
               }
           ];
};

ClientsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ClientsTab.prototype.showDetails = function(table, objects, row)
{
    var client        = objects.client;
    var identityZone  = objects.identity_zone;
    var serviceBroker = objects.service_broker;
    
    var first = true;
    
    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        first = false;
    }
    
    this.addJSONDetailsLinkRow(table, "Identifier", Format.formatString(client.client_id), objects, first);
    this.showDetailsArray(table, row[3], "Scope");
    this.showDetailsArray(table, row[4], "Authorized Grant Type");
    this.showDetailsArray(table, row[5], "Redirect URI");
    this.showDetailsArray(table, row[6], "Authority");
    this.showDetailsArray(table, row[7], "Auto Approve");
    this.addRowIfValue(this.addPropertyRow, table, "Show on Home Page", Format.formatBoolean, client.show_on_home_page);
    
    if (client.app_launch_url != null)
    {
        this.addURIRow(table, "App Launch URL", client.app_launch_url);
    }
    
    if (row[8] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[8]), client.client_id, AdminUI.showEvents);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Additional Information", Format.formatString, client.additional_information);
    
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
