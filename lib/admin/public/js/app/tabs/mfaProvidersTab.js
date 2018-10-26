
function MFAProvidersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__MFA_PROVIDERS, Constants.URL__MFA_PROVIDERS_VIEW_MODEL);
}

MFAProvidersTab.prototype = new Tab();

MFAProvidersTab.prototype.constructor = MFAProvidersTab;

MFAProvidersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"], [3, "asc"]];
};

MFAProvidersTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[3], value);
                                      },
                                      this)
               },
               {
                   title:  "Identity Zone",
                   width:  "300px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "Type",
                   width:  "300px",
                   render: Format.formatMFAString
               },
               {
                   title:  "Name",
                   width:  "300px",
                   render: Format.formatMFAString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Issuer",
                   width:  "300px",
                   render: Format.formatMFAString
               },
               {
                   title:  "Algorithm",
                   width:  "300px",
                   render: Format.formatMFAString
               },
               {
                   title:     "Digits",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Duration",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

MFAProvidersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected MFA providers?",
                                                         "Delete",
                                                         "Deleting MFA Providers",
                                                         Constants.URL__MFA_PROVIDERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

MFAProvidersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 4);
};

MFAProvidersTab.prototype.showDetails = function(table, objects, row)
{
    var identityZone = objects.identity_zone;
    var mfaProvider  = objects.mfa_provider;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addPropertyRow(table, "Type", Format.formatString(mfaProvider.type), first);
    this.addJSONDetailsLinkRow(table, "Name", Format.formatStringCleansed(mfaProvider.name), objects);
    this.addPropertyRow(table, "GUID", Format.formatString(mfaProvider.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(mfaProvider.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, mfaProvider.lastmodified);
    this.addRowIfValue(this.addPropertyRow, table, "Issuer", Format.formatString, row[7]);
    this.addRowIfValue(this.addPropertyRow, table, "Algorithm", Format.formatString, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "Digits", Format.formatNumber, row[9]);
    this.addRowIfValue(this.addPropertyRow, table, "Duration", Format.formatNumber, row[10]);

    var config = mfaProvider.config;

    if (config != null)
    {    
        try
        {
            var configJSON = jQuery.parseJSON(config);

            this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, configJSON.providerDescription);
        }
        catch (error)
        {
        }
    }
};
