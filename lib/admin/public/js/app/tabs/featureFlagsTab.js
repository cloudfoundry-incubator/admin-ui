
function FeatureFlagsTab(id)
{
    Tab.call(this, id, Constants.URL__FEATURE_FLAGS_VIEW_MODEL);
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
                   "sTitle":    Tab.prototype.formatCheckboxHeader(this.id),
                   "sWidth":    "2px",
                   "bSortable": false,
                   "mRender":   $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[1], value);
                   },
                   this),
               },
               {
                   "sTitle":  "Name",
                   "sWidth":  "300px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle": "GUID",
                   "sWidth": "200px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Updated",
                   "sWidth":  "180px",
                   "mRender": Format.formatString
               },
               {
                   "sTitle":  "Enabled",
                   "sWidth":  "80px",
                   "mRender": Format.formatBoolean
               }
           ];
};

FeatureFlagsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Enable",
                   click: $.proxy(function() 
                   {
                       this.updateChecked("Managing Feature Flags",
                                          Constants.URL__FEATURE_FLAGS,
                                          '{"enabled":true}');
                   }, 
                   this)
               },
               {
                   text: "Disable",
                   click: $.proxy(function() 
                   {
                       this.updateChecked("Managing Feature Flags",
                                          Constants.URL__FEATURE_FLAGS,
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
