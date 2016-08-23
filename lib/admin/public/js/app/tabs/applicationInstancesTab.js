
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
                   "title":     Tab.prototype.formatCheckboxHeader(this.id),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox(item[1], value);
                   },
                   this),
               },
               {
                   "title":  "Name",
                   "width":  "150px",
                   "render": Format.formatApplicationName
               },
               {
                   "title":  "Application GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":     "Index",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Instance ID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "State",
                   "width":  "80px",
                   "render": Format.formatStatus
               },
               {
                   "title":  "Started",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Metrics",
                   "width":  "170px",
                   "render": Format.formatString
               },
               {
                   "title":  "Diego",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Stack",
                   "width":  "200px",
                   "render": Format.formatStackName
               },
               {
                   "title":     "Memory",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Disk",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "% CPU",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Memory",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Disk",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":  "Target",
                   "width":  "200px",
                   "render": Format.formatTarget
               },
               {
                   "title":  "DEA",
                   "width":  "150px",
                   "render": function(value, type)
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
                   "title":  "Cell",
                   "width":  "150px",
                   "render": function(value, type)
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
                   text: "Restart",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to restart the selected application instances?",
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
    // Column 18 is only used as the details retrieval key and is not visible 
    this.itemClicked(-1, 18);
};

ApplicationInstancesTab.prototype.showDetails = function(table, objects, row)
{
    var application          = objects.application;
    var application_instance = objects.application_instance;
    var container            = objects.container;
    var organization         = objects.organization;
    var space                = objects.space;
    var stack                = objects.stack;

    var application_id   = null;
    var application_name = null;
    var droplet_sha1     = null;
    var instance_id      = null;
    var instance_index   = null;
    var state            = null;
    
    if (application_instance != null)
    {
        application_id   = application_instance.application_id;
        application_name = application_instance.application_name;
        droplet_sha1     = application_instance.droplet_sha1;
        instance_id      = application_instance.instance_id;
        instance_index   = application_instance.instance_index;
        state            = application_instance.state;
    }
    else if (container != null)
    {
        if (application != null)
        {
            application_name = application.name;
        }
        
        application_id = container.application_id;
        instance_index = container.instance_index;
    }
        
    var first = true;
    
    if (application_name != null)
    {
        this.addPropertyRow(table, "Name", Format.formatString(application_name), first);
        first = false;
    }
    
    var applicationLink = this.createFilterLink(Format.formatString(application_id), application_id, AdminUI.showApplications);
    var details = document.createElement("div");
    $(details).append(applicationLink);
    $(details).append(this.createJSONDetailsLink(objects));

    this.addRow(table, "Application GUID", details, first);
    
    this.addPropertyRow(table, "Index", Format.formatNumber(instance_index));
    this.addRowIfValue(this.addPropertyRow, table, "Instance ID", Format.formatString, instance_id);
    this.addRowIfValue(this.addPropertyRow, table, "State", Format.formatString, state);

    this.addRowIfValue(this.addPropertyRow, table, "Started", Format.formatDateNumber, row[6]);
    this.addRowIfValue(this.addPropertyRow, table, "Metrics", Format.formatDateString, row[7]);

    this.addRowIfValue(this.addPropertyRow, table, "Diego", Format.formatBoolean, row[8]);
    
    if (stack != null)
    {
        this.addFilterRow(table, "Stack", Format.formatStringCleansed(stack.name), stack.guid, AdminUI.showStacks);
        this.addPropertyRow(table, "Stack GUID", Format.formatString(stack.guid));
    }

    this.addRowIfValue(this.addPropertyRow, table, "Droplet Hash",    Format.formatString, droplet_sha1);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used",     Format.formatNumber, row[10]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",       Format.formatNumber, row[11]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",        Format.formatNumber, row[12]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[13]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[14]);

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

    if (row[16] != null)
    {
        this.addFilterRow(table, "DEA", Format.formatStringCleansed(row[16]), row[16], AdminUI.showDEAs);
    }
    
    if (row[17] != null)
    {
        this.addFilterRow(table, "Cell", Format.formatStringCleansed(row[17]), row[17], AdminUI.showCells);
    }
};

ApplicationInstancesTab.prototype.filterApplicationInstanceTable = function(event, value)
{
    $("#ApplicationInstancesTable").DataTable().rows().deselect();

    $("#ApplicationInstancesTable").DataTable().search(value).draw();

    event.stopPropagation();

    return false;
};
