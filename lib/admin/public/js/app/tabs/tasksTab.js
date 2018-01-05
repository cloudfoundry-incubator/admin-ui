
function TasksTab(id)
{
    Tab.call(this, id, Constants.FILENAME__TASKS, Constants.URL__TASKS_VIEW_MODEL);
}

TasksTab.prototype = new Tab();

TasksTab.prototype.constructor = TasksTab;

TasksTab.prototype.getColumns = function()
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
                   render: Format.formatTaskName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "State",
                   width:  "80px",
                   render: Format.formatStatus
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
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatApplicationName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:     "Task Sequence",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

TasksTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Stop",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to stop the selected tasks?",
                                                         "Stop",
                                                         "Stopping Tasks",
                                                         Constants.URL__TASKS,
                                                         "/cancel");
                                  },
                                  this)
               },
           ];
};

TasksTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

TasksTab.prototype.showDetails = function(table, objects, row)
{
    var application  = objects.application;
    var organization = objects.organization;
    var space        = objects.space;
    var task         = objects.task;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(task.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(task.guid));
    this.addPropertyRow(table, "State", Format.formatString(task.state));
    this.addPropertyRow(table, "Created", Format.formatDateString(task.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, task.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Memory", Format.formatNumber, task.memory_in_mb);
    this.addRowIfValue(this.addPropertyRow, table, "Disk", Format.formatNumber, task.disk_in_mb);
    this.addPropertyRow(table, "Command", Format.formatString(task.command));
    this.addRowIfValue(this.addPropertyRow, table, "Failure Reason", Format.formatString, task.failure_reason);

    if (application != null)
    {
        this.addFilterRow(table, "Application", Format.formatStringCleansed(application.name), application.guid, AdminUI.showApplications);
    }

    this.addPropertyRow(table, "Application GUID", Format.formatString(task.app_guid));
    this.addRowIfValue(this.addPropertyRow, table, "Application Task Sequence", Format.formatNumber, task.sequence_id);

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
};
