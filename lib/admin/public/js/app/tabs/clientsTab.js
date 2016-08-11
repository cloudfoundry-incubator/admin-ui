
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
                   "title":  "Updated",
                   "width":  "180px",
                   "render": Format.formatString
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
                   "title":     "Access Token Validity",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Refresh Token Validity",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Events",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Approvals",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Service Broker",
                   "width":  "200px",
                   "render": Format.formatServiceString
               },
               {
                   "title":  "Name",
                   "width":  "300px",
                   "render": Format.formatIdentityString
               },
               {
                   "title":  "GUID",
                   "width":  "300px",
                   "render": Format.formatString
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
    var client           = objects.client;
    var identityProvider = objects.identity_provider;
    var identityZone     = objects.identity_zone;
    var serviceBroker    = objects.service_broker;
    
    var first = true;
    
    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        first = false;
    }
    
    this.addJSONDetailsLinkRow(table, "Identifier", Format.formatString(client.client_id), objects, first);
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, client.lastmodified);
    this.showDetailsArray(table, row[4], "Scope");
    this.showDetailsArray(table, row[5], "Authorized Grant Type");
    this.showDetailsArray(table, row[6], "Redirect URI");
    this.showDetailsArray(table, row[7], "Authority");
    this.showDetailsArray(table, row[8], "Auto Approve");
    this.addRowIfValue(this.addPropertyRow, table, "Access Token Validity", Format.formatNumber, client.access_token_validity);
    this.addRowIfValue(this.addPropertyRow, table, "Refresh Token Validity", Format.formatNumber, client.refresh_token_validity);
    this.addRowIfValue(this.addPropertyRow, table, "Show on Home Page", Format.formatBoolean, client.show_on_home_page);
    
    if (client.app_launch_url != null)
    {
        this.addURIRow(table, "App Launch URL", client.app_launch_url);
    }
    
    if (row[11] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[11]), client.client_id, AdminUI.showEvents);
    }
    
    if (row[12] != null)
    {
        this.addFilterRow(table, "Approvals", Format.formatNumber(row[12]), client.client_id, AdminUI.showApprovals);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Additional Information", Format.formatString, client.additional_information);
    
    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
    }
    
    if (identityProvider != null)
    {
        this.addFilterRow(table, "Identity Provider", Format.formatStringCleansed(identityProvider.name), identityProvider.id, AdminUI.showIdentityProviders);
        this.addPropertyRow(table, "Identity Provider GUID", Format.formatString(identityProvider.id));
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
