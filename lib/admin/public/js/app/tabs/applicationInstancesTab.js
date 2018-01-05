
function ApplicationInstancesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__APPLICATION_INSTANCES, Constants.URL__APPLICATION_INSTANCES_VIEW_MODEL);
}

ApplicationInstancesTab.prototype = new Tab();

ApplicationInstancesTab.prototype.constructor = ApplicationInstancesTab;

ApplicationInstancesTab.prototype.getColumns = function()
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
                   width:  "150px",
                   render: Format.formatApplicationName
               },
               {
                   title:  "Application GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:     "Index",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Metrics",
                   width:  "170px",
                   render: Format.formatString
               },
               {
                   title:  "Diego",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Stack",
                   width:  "200px",
                   render: Format.formatStackName
               },
               {
                   title:     "Memory",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "% CPU",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               },
               {
                   title:  "DEA",
                   width:  "150px",
                   render: function(value, type)
                           {
                               if (value == null)
                               {
                                   return "";
                               }

                               if (Format.doFormatting(type))
                               {
                                   var result = "<div>" + value;

                                   if (value != null)
                                   {
                                       result += "<img onclick='ApplicationInstancesTab.prototype.filterApplicationInstanceTable(event, \"" + value + "\");' src='images/filter.png' style='height: 16px; width: 16px; margin-left: 5px; vertical-align: middle;'>";
                                   }

                                   result += "</div>";

                                   return result;
                               }

                               return value;
                           }
               },
               {
                   title:  "Cell",
                   width:  "150px",
                   render: function(value, type)
                           {
                               if (value == null)
                               {
                                   return "";
                               }

                               if (Format.doFormatting(type))
                               {
                                   var result = "<div>" + value;

                                   if (value != null)
                                   {
                                       result += "<img onclick='ApplicationInstancesTab.prototype.filterApplicationInstanceTable(event, \"" + value + "\");' src='images/filter.png' style='height: 16px; width: 16px; margin-left: 5px; vertical-align: middle;'>";
                                   }

                                   result += "</div>";

                                   return result;
                               }

                               return value;
                           }
               }
           ];
};

ApplicationInstancesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Restart",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to restart the selected application instances?",
                                                         "Restart",
                                                         "Restarting Application Instances",
                                                         Constants.URL__APPLICATIONS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

ApplicationInstancesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

ApplicationInstancesTab.prototype.showDetails = function(table, objects, row)
{
    var application  = objects.application;
    var container    = objects.container;
    var organization = objects.organization;
    var space        = objects.space;
    var stack        = objects.stack;

    var first = true;

    if (application != null)
    {
        this.addPropertyRow(table, "Name", Format.formatString(application.name), first);
        first = false;
    }

    var applicationLink = this.createFilterLink(Format.formatString(container.application_id), container.application_id, AdminUI.showApplications);
    var details = document.createElement("div");
    $(details).append(applicationLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Application GUID", details, first);

    this.addPropertyRow(table, "Index", Format.formatNumber(container.instance_index));
    this.addRowIfValue(this.addPropertyRow, table, "Metrics", Format.formatDateString, row[4]);

    this.addRowIfValue(this.addPropertyRow, table, "Diego", Format.formatBoolean, row[5]);

    if (stack != null)
    {
        this.addFilterRow(table, "Stack", Format.formatStringCleansed(stack.name), stack.guid, AdminUI.showStacks);
        this.addPropertyRow(table, "Stack GUID", Format.formatString(stack.guid));
    }

    this.addRowIfValue(this.addPropertyRow, table, "Memory Used",     Format.formatNumber, row[7]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",       Format.formatNumber, row[8]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",        Format.formatNumber, row[9]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[10]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[11]);

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
        this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }

    this.addFilterRowIfValue(table, "DEA", Format.formatStringCleansed, row[13], row[13], AdminUI.showDEAs);
    this.addFilterRowIfValue(table, "Cell", Format.formatStringCleansed, row[14], row[14], AdminUI.showCells);
};

ApplicationInstancesTab.prototype.filterApplicationInstanceTable = function(event, value)
{
    $("#ApplicationInstancesTable").DataTable().rows().deselect();

    $("#ApplicationInstancesTable").DataTable().search(value).draw();

    event.stopPropagation();

    return false;
};
