
function ApplicationsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__APPLICATIONS, Constants.URL__APPLICATIONS_VIEW_MODEL);
}

ApplicationsTab.prototype = new Tab();

ApplicationsTab.prototype.constructor = ApplicationsTab;

ApplicationsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.applicationsEnvironmentVariablesTable = Table.createTable("ApplicationsEnvironmentVariables", this.getApplicationsEnvironmentVariablesColumns(), [[0, "asc"]], null, this.getApplicationsEnvironmentVariablesActions(), Constants.FILENAME__APPLICATION_ENVIRONMENT_VARIABLES, null, null);
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
                       return this.formatCheckbox(this.id, item[1], value);
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
                   "title":  "Desired State",
                   "width":  "80px",
                   "render": Format.formatStatus
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
                   "title":  "Diego",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "SSH Enabled",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Docker Image",
                   "width":  "10px",
                   "render": Format.formatBoolean
               },
               {
                   "title":  "Stack",
                   "width":  "200px",
                   "render": Format.formatStackName
               },
               {
                   "title":  "Buildpack",
                   "width":  "100px",
                   "render": Format.formatBuildpackName
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
                   "title":     "Route Mappings",
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
                   "title":     "Tasks",
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
                       this.renameSingleChecked(this.id,
                                                "Rename Application",
                                                "Managing Applications",
                                                Constants.URL__APPLICATIONS);
                   },
                   this)
               },
               {
                   text: "Start",
                   click: $.proxy(function()
                   {
                       this.updateChecked(this.id,
                                          "Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          "",
                                          '{"state":"STARTED"}');
                   },
                   this)
               },
               {
                   text: "Stop",
                   click: $.proxy(function()
                   {
                       this.updateChecked(this.id,
                                          "Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          "",
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
                   text: "Enable Diego",
                   click: $.proxy(function()
                   {
                       this.updateChecked(this.id,
                                          "Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          "",
                                          '{"diego":true}');
                   },
                   this)
               },
               {
                   text: "Disable Diego",
                   click: $.proxy(function()
                   {
                       this.updateChecked(this.id,
                                          "Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          "",
                                          '{"diego":false}');
                   },
                   this)
               },
               {
                   text: "Enable SSH",
                   click: $.proxy(function()
                   {
                       this.updateChecked(this.id,
                                          "Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          "",
                                          '{"enable_ssh":true}');
                   },
                   this)
               },
               {
                   text: "Disable SSH",
                   click: $.proxy(function()
                   {
                       this.updateChecked(this.id,
                                          "Managing Applications",
                                          Constants.URL__APPLICATIONS,
                                          "",
                                          '{"enable_ssh":false}');
                   },
                   this)
               },
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked(this.id,
                                          "Are you sure you want to delete the selected applications?",
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
                       this.deleteChecked(this.id,
                                          "Are you sure you want to delete the selected applications and their associated service bindings?",
                                          "Delete Recursive",
                                          "Deleting Applications and Associated Service Bindings",
                                          Constants.URL__APPLICATIONS,
                                          "?recursive=true");
                   },
                   this)
               }
           ];
};

ApplicationsTab.prototype.getApplicationsEnvironmentVariablesColumns = function()
{
    return [
               {
                   "title":     Tab.prototype.formatCheckboxHeader("ApplicationsEnvironmentVariables"),
                   "type":      "html",
                   "width":     "2px",
                   "orderable": false,
                   "render":    $.proxy(function(value, type, item)
                   {
                       return this.formatCheckbox("ApplicationsEnvironmentVariables", item[1], value);
                   },
                   this),
               },
               {
                   "title":  "Key",
                   "width":  "200px",
                   "render": Format.formatKey
               },
               {
                   "title":  "Value",
                   "width":  "400px",
                   "render": Format.formatValue
               }
           ];
};

ApplicationsTab.prototype.getApplicationsEnvironmentVariablesActions = function()
{
    return [
               {
                   text: "Delete",
                   click: $.proxy(function()
                   {
                       this.deleteChecked("ApplicationsEnvironmentVariables",
                                          "Are you sure you want to delete the application's selected environment variables?",
                                          "Delete",
                                          "Deleting Application Environment Variable",
                                          Constants.URL__APPLICATIONS,
                                          "");
                   },
                   this)
               }
           ];
};

ApplicationsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#ApplicationsEnvironmentVariablesTableContainer").hide();
};

ApplicationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ApplicationsTab.prototype.showDetails = function(table, objects, row)
{
    var application          = objects.application;
    var currentDroplet       = objects.current_droplet;
    var currentPackage       = objects.current_package;
    var environmentVariables = objects.environment_variables;
    var latestDroplet        = objects.latest_droplet;
    var latestPackage        = objects.latest_package;
    var organization         = objects.organization;
    var process              = objects.process;
    var space                = objects.space;
    var stack                = objects.stack;

    var droplet = currentDroplet;

    if (droplet == null)
    {
        droplet = latestDroplet;
    }
    var packag = currentPackage;

    if (packag == null)
    {
        packag = latestPackage;
    }

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(application.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(application.guid));
    this.addRowIfValue(this.addPropertyRow, table, "Desired State", Format.formatString, row[3]);
    this.addRowIfValue(this.addPropertyRow, table, "State", Format.formatString, row[4]);
    this.addRowIfValue(this.addPropertyRow, table, "Package State", Format.formatString, row[5]);

    if (droplet != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Staging Failed Reason", Format.formatString, droplet.error_id);
        this.addRowIfValue(this.addPropertyRow, table, "Staging Failed Description", Format.formatString, droplet.error_description);
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(application.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, application.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Diego", Format.formatBoolean, row[9]);
    this.addRowIfValue(this.addPropertyRow, table, "SSH Enabled", Format.formatBoolean, row[10]);

    if (packag != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Docker Image", Format.formatString, packag.docker_image);
    }

    this.addFilterRowIfValue(table, "Stack", Format.formatStringCleansed, row[12], row[12], AdminUI.showStacks);

    if (stack != null)
    {
        this.addPropertyRow(table, "Stack GUID", Format.formatString(stack.guid));
    }

    if (row[13] != null & row[14] != null)
    {
        this.addFilterRow(table, "Buildpack", Format.formatStringCleansed(row[13]), row[14], AdminUI.showBuildpacks);
    }

    this.addRowIfValue(this.addPropertyRow, table, "Buildpack GUID", Format.formatString, row[14]);

    if (droplet != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Detected Buildpack", Format.formatString, droplet.buildpack_receipt_detect_output);
    }

    if (process != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Command", Format.formatString, process.command);

        if (droplet != null)
        {
            var processType = process.type;
            var processTypes = droplet.process_types;

            if (processType != null && processTypes != null)
            {    
                try
                {
                    var processTypesJSON = jQuery.parseJSON(processTypes);

                    this.addRowIfValue(this.addPropertyRow, table, "Detected Start Command", Format.formatString, processTypesJSON[processType]);
                }
                catch (error)
                {
                }
            }
        }

        this.addRowIfValue(this.addPropertyRow, table, "File Descriptors", Format.formatNumber, process.file_descriptors);
    }
    
    this.addFilterRowIfValue(table, "Events", Format.formatNumber, row[15], application.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Instances", Format.formatNumber, row[16], application.guid, AdminUI.showApplicationInstances);
    this.addFilterRowIfValue(table, "Route Mappings", Format.formatNumber, row[17], application.guid, AdminUI.showRouteMappings);
    this.addFilterRowIfValue(table, "Service Bindings", Format.formatNumber, row[18], application.guid, AdminUI.showServiceBindings);
    this.addFilterRowIfValue(table, "Tasks", Format.formatNumber, row[19], application.guid, AdminUI.showTasks);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[20]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",   Format.formatNumber, row[21]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",    Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved",  Format.formatNumber, row[23]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved", Format.formatNumber, row[24]);

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
    
    if (environmentVariables != null)
    {
        var environmentVariableFound = false;

        var applicationsEnvironmentVariablesTableData = [];

        for (var key in environmentVariables)
        {
            environmentVariableFound = true;

            var value = environmentVariables[key];

            var applicationsEnvironmentVariableRow = [];

            applicationsEnvironmentVariableRow.push(application.guid + "/environment_variables/" + encodeURIComponent(key));
            applicationsEnvironmentVariableRow.push(key);
            applicationsEnvironmentVariableRow.push(JSON.stringify(value));

            applicationsEnvironmentVariablesTableData.push(applicationsEnvironmentVariableRow);
        }

        if (environmentVariableFound)
        {
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ApplicationsEnvironmentVariablesTableContainer").show();

            this.applicationsEnvironmentVariablesTable.api().clear().rows.add(applicationsEnvironmentVariablesTableData).draw();
        }
    }
};

ApplicationsTab.prototype.restageApplications = function()
{
    var apps = this.getChecked(this.id);

    if ((!apps) || (apps.length == 0))
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
