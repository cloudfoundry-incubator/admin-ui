
function FeatureFlagsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__FEATURE_FLAGS, Constants.URL__FEATURE_FLAGS_VIEW_MODEL);
}

FeatureFlagsTab.prototype = new Tab();

FeatureFlagsTab.prototype.constructor = FeatureFlagsTab;

FeatureFlagsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

FeatureFlagsTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "300px",
                   render: Format.formatString
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
                   title:  "Enabled",
                   width:  "10px",
                   render: Format.formatBoolean
               }
           ];
};

FeatureFlagsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Enable",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Feature Flags",
                                                         Constants.URL__FEATURE_FLAGS,
                                                         "",
                                                         '{"enabled":true}');
                                  },
                                  this)
               },
               {
                   text:  "Disable",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Feature Flags",
                                                         Constants.URL__FEATURE_FLAGS,
                                                         "",
                                                         '{"enabled":false}');
                                  },
                                  this)
               }
           ];
};

FeatureFlagsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

FeatureFlagsTab.prototype.showDetails = function(table, featureFlag, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(featureFlag.name), featureFlag, true);
    this.addRowIfValue(this.addPropertyRow, table, "GUID", Format.formatString, featureFlag.guid);
    this.addRowIfValue(this.addPropertyRow, table, "Created", Format.formatDateString, featureFlag.created_at);
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, featureFlag.updated_at);

    this.addRowIfValue(this.addPropertyRow, table, "Enabled", Format.formatBoolean, featureFlag.enabled);
    this.addRowIfValue(this.addPropertyRow, table, "Error Message", Format.formatString, featureFlag.error_message);
};
