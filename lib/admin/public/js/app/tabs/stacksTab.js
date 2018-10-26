
function StacksTab(id)
{
    Tab.call(this, id, Constants.FILENAME__STACKS, Constants.URL__STACKS_VIEW_MODEL);
}

StacksTab.prototype = new Tab();

StacksTab.prototype.constructor = StacksTab;

StacksTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

StacksTab.prototype.getColumns = function()
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
                   width:  "200px",
                   render: Format.formatStackName
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
                   title:     "Buildpacks",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Applications",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Application Instances",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Description",
                   width:  "300px",
                   render: Format.formatStringCleansed
               }
           ];
};

StacksTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected stacks?",
                                                         "Delete",
                                                         "Deleting Stacks",
                                                         Constants.URL__STACKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

StacksTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

StacksTab.prototype.showDetails = function(table, stack, row)
{
    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(stack.name), stack, true);
    this.addPropertyRow(table, "GUID", Format.formatString(stack.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(stack.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, stack.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Description", Format.formatString, stack.description);
    this.addFilterRowIfValue(table, "Buildpacks", Format.formatNumber,  row[5], stack.name, AdminUI.showBuildpacks);
    this.addFilterRowIfValue(table, "Applications", Format.formatNumber,  row[6], stack.name, AdminUI.showApplications);
    this.addFilterRowIfValue(table, "Application Instances", Format.formatNumber, row[7], stack.name, AdminUI.showApplicationInstances);
};
