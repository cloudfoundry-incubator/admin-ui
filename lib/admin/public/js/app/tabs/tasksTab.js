
function TasksTab(id)
{
    Tab.call(this, id, Constants.URL__TASKS_VIEW_MODEL);
}

TasksTab.prototype = new Tab();

TasksTab.prototype.constructor = TasksTab;

TasksTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    $("#TaskShowTimestamps").click($.proxy(this.handleTaskCheckboxClicked, this));
    $("#TaskShowStandardOut").click($.proxy(this.handleTaskCheckboxClicked, this));
    $("#TaskShowStandardError").click($.proxy(this.handleTaskCheckboxClicked, this));

    $("#TasksTable_length").change($.proxy(this.resize, this));
};

TasksTab.prototype.getInitialSort = function()
{
    return [[2, "desc"]];
};

TasksTab.prototype.getColumns = function()
{
    return [
               {
                   "title":  "Command",
                   "width":  "500px",
                   "render": Format.formatString
               },
               {
                   "title":  "State",
                   "width":  "80px",
                   "render": Format.formatString
               },
               {
                   "title":  "Started",
                   "width":  "170px",
                   "render": Format.formatString
               }
           ];
};

TasksTab.prototype.refresh = function()
{
    Tab.prototype.refresh.call(this);
    
    var rows = this.table.api().rows().data();
    
    for (var index = 0; index < rows.length; index++)
    {
        if (rows[index][1] == Constants.STATUS__RUNNING)
        {
            var refreshFunction = $.proxy(function()
            {
                if ($("#Tasks").hasClass("menuItemSelected"))
                {
                    this.refresh();
                }
            },
            this);

            setTimeout(refreshFunction, AdminUI.settings.tasks_refresh_interval);
            
            break;
        }
    }
};

TasksTab.prototype.clickHandler = function()
{
    var tableTools = TableTools.fnGetInstance("TasksTable");

    var selected = tableTools.fnGetSelectedData();

    if (selected.length > 0)
    {
        var taskID = selected[0][3];

        this.retrieveTask(taskID, false);
    }
    else
    {
        if (!this.refreshing)
        {
            $("#TaskContainer").hide();

            if (this.taskDeferred != null)
            {
                this.taskDeferred.abort();
            }
        }
    }
};

TasksTab.prototype.retrieveTask = function(taskID, updates)
{
    if (this.taskDeferred != null)
    {
        this.taskDeferred.abort();
    }

    this.taskDeferred = $.ajax({
                                   url:      Constants.URL__TASK_STATUS,
                                   dataType: "json",
                                   data:     {task_id: taskID, updates: updates},
                                   type:     "GET"
                               });

    this.taskDeferred.done($.proxy(function(task, status)
    {
        this.handleTaskRetrievedSuccessfully(task, updates);
    },
    this));
    
    this.taskDeferred.fail(function(xhr, status, error)
    {
    });
};

TasksTab.prototype.handleTaskRetrievedSuccessfully = function(task, updates)
{
    var showTimestamps     = $("#TaskShowTimestamps").prop("checked");
    var showStandardOutput = $("#TaskShowStandardOut").prop("checked");
    var showStandardError  = $("#TaskShowStandardError").prop("checked");

    var contents = updates ? $("#TaskContents").text() : "";

    for (var index in task.output)
    {
        var row = task.output[index];

        if (row.text != null)
        {
            if (((row.type == "out") && showStandardOutput) || ((row.type == "err") && showStandardError))
            {
                if (showTimestamps)
                {
                    contents += Format.formatDateNumber(row.time, true) + " ";
                }

                if (showStandardOutput && showStandardError)
                {
                    contents += "[" + row.type + "] ";
                }

                contents += row.text;
            }
        }
    }

    $("#TaskContents").text(contents); 

    $("#TaskContainer").show();

    this.resize();

    if ($("#Tasks").hasClass("menuItemSelected"))
    {
        if (task.state == Constants.STATUS__RUNNING)
        {
            this.retrieveTask(task.id, true);
        }
    }
};

TasksTab.prototype.handleTaskCheckboxClicked = function()
{
    this.clickHandler();
};

TasksTab.prototype.resize = function()
{
    var windowHeight = $(window).height();

    var tablePosition = $("#TasksTableContainer").offset();
    var tableHeight   = $("#TasksTableContainer").outerHeight(true);

    var height = windowHeight - tablePosition.top - tableHeight - 40;

    $("#TaskContents").height(Math.max(height, 300));
};
