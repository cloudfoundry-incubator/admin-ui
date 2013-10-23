
function TasksTab(id)
{
    this.url = Constants.URL__TASKS;

    Tab.call(this, id);
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
}

TasksTab.prototype.getInitialSort = function()
{
    return [[2, "desc"]];
}

TasksTab.prototype.getColumns = function()
{
    return [
               {
                   "sTitle": "Command",
                   "sWidth": "500px"
               },
               {
                   "sTitle" : "State",
                   "sWidth":  "80px"
               },
               {
                   "sTitle":  "Started",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateNumber
               }
           ];
}

TasksTab.prototype.refresh = function(reload)
{
    reload = true;

    Data.get(this.url, reload).done($.proxy(function(result)
    {
        this.updateData([result], reload);

        var refresh = false;

        for (var index in result.response.items)
        {
            var task = result.response.items[index];

            if (task.state == Constants.STATUS__RUNNING)
            {
                refresh = true;
                break;
            }
        }

        if (refresh)
        {
            var refreshFunction = $.proxy(function()
            {
                if ($("#Tasks").hasClass("menuItemSelected"))
                {
                    this.refresh(true);
                }
            },
            this);

            setTimeout(refreshFunction, AdminUI.settings.tasks_refresh_interval);   
        }
    },
    this));
}

TasksTab.prototype.updateTableRow = function(row, task)
{
    row.push(task.command);
    row.push(task.state);
    row.push(task.started);

    row.push(task.id);
}

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
}

TasksTab.prototype.retrieveTask = function(taskID, updates)
{
    if (this.taskDeferred != null)
    {
        this.taskDeferred.abort();
    }

    this.taskDeferred = $.ajax({
                                   url: Constants.URL__TASK_STATUS,
                                   dataType: "json",
                                   data: {task_id: taskID, updates: updates},
                                   type: "GET"
                               });

    this.taskDeferred.done($.proxy(function(task, status)
    {
        this.handleTaskRetrievedSuccessfully(task, updates);
    },
    this));

    this.taskDeferred.fail(function(xhr, status, error)
    {

    });
}

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
        // We have to let the auto refresh on the page change the status of the selected
        // task because for some reason fnUpdate causes a saveTableScrollPosition() to
        // be called and wrapping the flags around it doesn't prevent it either.
        //else
        //{
        //   
        //    var tableTools = TableTools.fnGetInstance("TasksTable");
        //    var selected = tableTools.fnGetSelected();                  
        //                  
        //    AdminUI.ignoreScroll = true;
        //    AdminUI.tasksTable.fnUpdate(Constants.STATUS__FINISHED, selected[0], 1);
        //    AdminUI.ignoreScroll = false;
        //}
    }
}

TasksTab.prototype.handleTaskCheckboxClicked = function()
{
    this.clickHandler();
}

TasksTab.prototype.resize = function()
{
    var windowHeight = $(window).height();

    var tablePosition = $("#TasksTableContainer").offset();
    var tableHeight   = $("#TasksTableContainer").outerHeight(true);

    var height = windowHeight - tablePosition.top - tableHeight - 40;

    $("#TaskContents").height(Math.max(height, 300));
}

