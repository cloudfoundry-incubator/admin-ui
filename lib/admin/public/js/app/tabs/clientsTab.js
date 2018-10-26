
function ClientsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__CLIENTS, Constants.URL__CLIENTS_VIEW_MODEL);
}

ClientsTab.prototype = new Tab();

ClientsTab.prototype.constructor = ClientsTab;

ClientsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"]];
};

ClientsTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[2], value);
                                      },
                                      this)
               },
               {
                   title:  "Identity Zone",
                   width:  "300px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "Identifier",
                   width:  "300px",
                   render: Format.formatUserString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Scopes",
                   width:  "200px",
                   render: Format.formatClientStrings
               },
               {
                   title:  "Authorized Grant Types",
                   width:  "200px",
                   render: Format.formatClientStrings
               },
               {
                   title:  "Redirect URIs",
                   width:  "200px",
                   render: Format.formatClientStrings
               },
               {
                   title:  "Authorities",
                   width:  "200px",
                   render: Format.formatClientStrings
               },
               {
                   title:  "Auto Approve",
                   width:  "200px",
                   render: Format.formatClientStrings
               },
               {
                   title:  "Required User Groups",
                   width:  "200px",
                   render: Format.formatClientStrings
               },
               {
                   title:     "Access Token Validity",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Refresh Token Validity",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Approvals",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Revocable Tokens",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Service Broker",
                   width:  "200px",
                   render: Format.formatServiceString
               }
           ];
};

ClientsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Revoke Tokens",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to revoke the selected clients' tokens?",
                                                         "Revoke",
                                                         "Revoking Client Tokens",
                                                         Constants.URL__CLIENTS,
                                                         "/tokens");
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected clients?",
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
    this.itemClicked(-1, 0);
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
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "Identifier", Format.formatString(client.client_id), objects, first);
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, client.lastmodified);
    this.showDetailsArray(table, row[4], "Scope");
    this.showDetailsArray(table, row[5], "Authorized Grant Type");
    this.showDetailsArray(table, row[6], "Redirect URI");
    this.showDetailsArray(table, row[7], "Authority");
    this.showDetailsArray(table, row[8], "Auto Approve");
    this.showDetailsArray(table, row[9], "Required User Group");
    this.addRowIfValue(this.addPropertyRow, table, "Access Token Validity", Format.formatNumber, client.access_token_validity);
    this.addRowIfValue(this.addPropertyRow, table, "Refresh Token Validity", Format.formatNumber, client.refresh_token_validity);
    this.addRowIfValue(this.addPropertyRow, table, "Show on Home Page", Format.formatBoolean, client.show_on_home_page);

    if (client.app_launch_url != null)
    {
        this.addURIRow(table, "App Launch URL", client.app_launch_url);
    }

    this.addFilterRowIfValue(table, "Events", Format.formatNumber, row[12], client.client_id, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Approvals", Format.formatNumber, row[13], client.client_id, AdminUI.showApprovals);
    this.addFilterRowIfValue(table, "Revocable Tokens", Format.formatNumber, row[14], client.client_id, AdminUI.showRevocableTokens);
    this.addRowIfValue(this.addPropertyRow, table, "Additional Information", Format.formatString, client.additional_information);

    if (serviceBroker != null)
    {
        this.addFilterRow(table, "Service Broker", Format.formatStringCleansed(serviceBroker.name), serviceBroker.guid, AdminUI.showServiceBrokers);
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
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
