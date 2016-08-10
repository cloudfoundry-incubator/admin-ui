
function ApplicationsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__APPLICATIONS, Constants.URL__APPLICATIONS_VIEW_MODEL);
}

ApplicationsTab.prototype = new Tab();

ApplicationsTab.prototype.constructor = ApplicationsTab;

ApplicationsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

ApplicationsTab.prototype.getColumns = function()
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
                   "title":  "GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "State",
                   "width":  "80px",
                   "render": Format.formatStatus
               },
               {
                   "title":  "Package State",
                   "width":  "80px",
                   "render": Format.formatStatus
               },
               {
                   "title":  "Staging Failed Reason",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":  "Created",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "Updated",
                   "width":  "180px",
                   "render": Format.formatString
               },
               {
                   "title":  "URIs",
                   "width":  "200px",
                   "render": Format.formatURIs
               },
               {
                   "title":  "Diego",
                   "width":  "80px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Stack",
                   "width":  "200px",
                   "render": Format.formatStackName
               },
               {
                   "title":  "Buildpacks",
                   "width":  "100px",
                   "render": Format.formatBuildpacks
               },
               {
                   "title":  "Buildpack GUID",
                   "width":  "200px",
                   "render": Format.formatString
               },
               {
                   "title":     "Events",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Instances",
                   "width":     "70px",
                   "className": "cellRightAlign",
                   "render":    Format.formatNumber
               },
               {
                   "title":     "Service Bindings",
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
               }
           ];
};

ApplicationsTab.prototype.getActions = function()
{
    return [
               {
                   text: "Rename",
                   click: $.proxy(function()
                   {
                       this.renameSingleChecked("Rename Application",
                                                "Managing Applications",
                                                Constants.URL__APPLICATIONS);
                   }, 
                   this)
               },{
                   text: "Start",
                   click: $.proxy(function()
                   {
                       this.updateChecked("Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          '{"state":"STARTED"}');
                   }, 
                   this)
               },
               {
                   text: "Stop",
                   click: $.proxy(function()
                   {
                       this.updateChecked("Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          '{"state":"STOPPED"}');
                   }, 
                   this)
               },
               {
                   text: "Restage",
                   click: $.proxy(function()
                   {
                       this.restageApplications();
                   }, 
                   this)
               },
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected applications?",
                                          "Delete",
                                          "Deleting Applications",
                                          Constants.URL__APPLICATIONS,
                                          "");
                   }, 
                   this)
               },
               {
                   text: "Delete Recursive",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("Are you sure you want to delete the selected applications and their associated service bindings?",
                                          "Delete Recursive",
                                          "Deleting Applications and Associated Service Bindings",
                                          Constants.URL__APPLICATIONS,
                                          "?recursive=true");
                   }, 
                   this)
               }
           ];
};

ApplicationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ApplicationsTab.prototype.showDetails = function(table, objects, row)
{
    var application  = objects.application;
    var droplet      = objects.droplet;
    var organization = objects.organization;
    var space        = objects.space;
    var stack        = objects.stack;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(application.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(application.guid));
    this.addPropertyRow(table, "State", Format.formatString(application.state));
    this.addPropertyRow(table, "Package State", Format.formatString(application.package_state));
    this.addRowIfValue(this.addPropertyRow, table, "Staging Failed Reason", Format.formatString, application.staging_failed_reason);
    this.addRowIfValue(this.addPropertyRow, table, "Staging Failed Description", Format.formatString, application.staging_failed_description);
    this.addPropertyRow(table, "Created", Format.formatDateString(application.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, application.updated_at);

    var appURIs = row[8];
    if (appURIs != null)
    {
        for (var appURIIndex = 0; appURIIndex < appURIs.length; appURIIndex++)
        {
            this.addURIRow(table, "URI", "http://" + appURIs[appURIIndex]);
        }
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Diego", Format.formatBoolean, application.diego);
    
    if (stack != null)
    {
        this.addFilterRow(table, "Stack", Format.formatStringCleansed(stack.name), stack.guid, AdminUI.showStacks);
    }
    
    if (row[11] != null)
    {
        var buildpackArray = Utilities.splitByCommas(row[11]);
        for (var buildpackIndex = 0; buildpackIndex < buildpackArray.length; buildpackIndex++)
        {
            var buildpack = buildpackArray[buildpackIndex];
            this.addPropertyRow(table, "Buildpack", Format.formatString(buildpack)); 
        }
    }
    
    // Intentionally use the cell to check for null since a detected_buildpack_guid is not cleared when its related buildpack is deleted
    if (row[12] != null)
    {
        this.addFilterRow(table, "Buildpack GUID", Format.formatString(row[12]), row[12], AdminUI.showBuildpacks);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Command", Format.formatString, application.command);
    
    if (droplet != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Detected Start Command", Format.formatString, droplet.detected_start_command);
    }
    
    this.addRowIfValue(this.addPropertyRow, "File Descriptors", Format.formatNumber, application.file_descriptors);
    this.addRowIfValue(this.addPropertyRow, table, "Droplet Hash", Format.formatString, application.droplet_hash);

    if (row[13] != null)
    {
        this.addFilterRow(table, "Events", Format.formatNumber(row[13]), application.guid, AdminUI.showEvents);
    }
    
    if (row[14] != null)
    {
        this.addFilterRow(table, "Instances", Format.formatNumber(row[14]), application.guid, AdminUI.showApplicationInstances);
    }
    
    if (row[15] != null)
    {
        this.addFilterRow(table, "Service Bindings", Format.formatNumber(row[15]), application.guid, AdminUI.showServiceBindings);
    }
    
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",   Format.formatNumber, row[17]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",    Format.formatNumber, row[18]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved",  Format.formatNumber, application.memory);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved", Format.formatNumber, application.disk_quota);

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
    }
};

ApplicationsTab.prototype.restageApplications = function()
{
    var apps = this.getChecked();

    if (!apps || apps.length == 0)
    {
        return;
    }

    var processed = 0;
    
    var errorApps = [];
    
    AdminUI.showModalDialogProgress("Managing Applications");

    for (var appIndex = 0; appIndex < apps.length; appIndex++)
    {
        var app = apps[appIndex];

        var deferred = $.ajax({
                                  type:            "POST",
                                  url:             Constants.URL__APPLICATIONS + "/" + app.key + "/restage",
                                  contentType:     "application/json; charset=utf-8",
                                  dataType:        "json",
                                  data:            "{}",
                                  // Need application name inside the fail method
                                  applicationName: app.name
        });
        
        deferred.fail(function(xhr, status, error)
        {
            errorApps.push({
                               label: this.applicationName,
                               xhr:   xhr
                           });
        });
      
        deferred.always(function(xhr, status, error)
        {
            processed++;
            
            if (processed == apps.length)
            {
                if (errorApps.length > 0)
                {
                    AdminUI.showModalDialogErrorTable(errorApps);
                }
                else
                {
                    AdminUI.showModalDialogSuccess();
                }
        
                AdminUI.refresh();
            }
        });
    }
};
