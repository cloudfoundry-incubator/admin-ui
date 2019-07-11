
function TasksTab(id)
{
    Tab.call(this, id, Constants.FILENAME__TASKS, Constants.URL__TASKS_VIEW_MODEL);
}

TasksTab.prototype = new Tab();

TasksTab.prototype.constructor = TasksTab;

TasksTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.tasksLabelsTable = Table.createTable("TasksLabels", this.getTasksLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getTasksLabelsActions(), Constants.FILENAME__TASK_LABELS, null, null);

    this.tasksAnnotationsTable = Table.createTable("TasksAnnotations", this.getTasksAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getTasksAnnotationsActions(), Constants.FILENAME__TASK_ANNOTATIONS, null, null);
};

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

TasksTab.prototype.getTasksLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("TasksLabels"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("TasksLabels", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
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
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

TasksTab.prototype.getTasksLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("TasksLabels",
                                                         "Are you sure you want to delete the task's selected labels?",
                                                         "Delete",
                                                         "Deleting Task Label",
                                                         Constants.URL__TASKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

TasksTab.prototype.getTasksAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("TasksAnnotations"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("TasksAnnotations", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
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
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

TasksTab.prototype.getTasksAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("TasksAnnotations",
                                                         "Are you sure you want to delete the task's selected annotations?",
                                                         "Delete",
                                                         "Deleting Task Annotation",
                                                         Constants.URL__TASKS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

TasksTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#TasksLabelsTableContainer").hide();
    $("#TasksAnnotationsTableContainer").hide();
};

TasksTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

TasksTab.prototype.showDetails = function(table, objects, row)
{
    var annotations  = objects.annotations;
    var application  = objects.application;
    var labels       = objects.labels;
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

    if ((labels != null) && (labels.length > 0))
    {
        var labelsTableData = [];

        for (var labelIndex = 0; labelIndex < labels.length; labelIndex++)
        {
            var wrapper = labels[labelIndex];
            var label   = wrapper.label;

            var path = label.resource_guid + "/metadata/labels/" + encodeURIComponent(label.key_name);
            if (label.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(label.key_prefix);
            }

            var labelRow = [];

            labelRow.push(path);
            labelRow.push(label.key_prefix);
            labelRow.push(label.key_name);
            labelRow.push(label.guid);
            labelRow.push(wrapper.created_at_rfc3339);
            labelRow.push(wrapper.updated_at_rfc3339);
            labelRow.push(label.value);

            labelsTableData.push(labelRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#TasksLabelsTableContainer").show();

        this.tasksLabelsTable.api().clear().rows.add(labelsTableData).draw();
    }

    if ((annotations != null) && (annotations.length > 0))
    {
        var annotationsTableData = [];

        for (var annotationIndex = 0; annotationIndex < annotations.length; annotationIndex++)
        {
            var wrapper    = annotations[annotationIndex];
            var annotation = wrapper.annotation;

            var path = annotation.resource_guid + "/metadata/annotations/" + encodeURIComponent(annotation.key);
            if (annotation.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(annotation.key_prefix);
            }

            var annotationRow = [];

            annotationRow.push(path);
            annotationRow.push(annotation.key_prefix);
            annotationRow.push(annotation.key);
            annotationRow.push(annotation.guid);
            annotationRow.push(wrapper.created_at_rfc3339);
            annotationRow.push(wrapper.updated_at_rfc3339);
            annotationRow.push(annotation.value);

            annotationsTableData.push(annotationRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#TasksAnnotationsTableContainer").show();

        this.tasksAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
