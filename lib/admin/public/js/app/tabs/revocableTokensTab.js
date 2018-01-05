
function RevocableTokensTab(id)
{
    Tab.call(this, id, Constants.FILENAME__REVOCABLE_TOKENS, Constants.URL__REVOCABLE_TOKENS_VIEW_MODEL);
}

RevocableTokensTab.prototype = new Tab();

RevocableTokensTab.prototype.constructor = RevocableTokensTab;

RevocableTokensTab.prototype.getColumns = function()
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
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Issued",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Expires",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Format",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Response Type",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Scopes",
                   width:  "200px",
                   render: Format.formatRevocableTokenStrings
               },
               {
                   title:  "Client",
                   width:  "300px",
                   render: Format.formatUserString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatUserString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               }
           ];
};

RevocableTokensTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Revoke",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to revoke the selected tokens?",
                                                         "Delete",
                                                         "Deleting Revocable Tokens",
                                                         Constants.URL__REVOCABLE_TOKENS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

RevocableTokensTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

RevocableTokensTab.prototype.showDetails = function(table, objects, row)
{
    var client         = objects.client;
    var identityZone   = objects.identity_zone;
    var revocableToken = objects.revocable_token;
    var user           = objects.user_uaa;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "GUID", Format.formatString(revocableToken.token_id), objects, first);
    this.addPropertyRow(table, "Issued", Format.formatDateNumber(revocableToken.issued_at));
    this.addPropertyRow(table, "Expires", Format.formatDateNumber(revocableToken.expires_at));
    this.addRowIfValue(this.addPropertyRow, table, "Format", Format.formatString, revocableToken.format);
    this.addPropertyRow(table, "Response Type", Format.formatString(revocableToken.response_type));
    this.showDetailsArray(table, row[7], "Scope");
    this.addFilterRow(table, "Client", Format.formatStringCleansed(row[8]), row[8], AdminUI.showClients);
    this.addFilterRowIfValue(table, "User", Format.formatStringCleansed, row[9], revocableToken.user_id, AdminUI.showUsers);
    this.addRowIfValue(this.addPropertyRow, table, "User GUID", Format.formatString, revocableToken.user_id);
};

RevocableTokensTab.prototype.showDetailsArray = function(table, array, label)
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
