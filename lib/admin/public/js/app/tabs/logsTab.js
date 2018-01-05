
function LogsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__LOGS, Constants.URL__LOGS_VIEW_MODEL);
}

LogsTab.prototype = new Tab();

LogsTab.prototype.constructor = LogsTab;

LogsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    $("#LogFirstButton").click($.proxy(this.handleLogFirstClicked, this));
    $("#LogBackButton").click($.proxy(this.handleLogBackClicked, this));
    $("#LogForwardButton").click($.proxy(this.handleLogForwardClicked, this));
    $("#LogLastButton").click($.proxy(this.handleLogLastClicked, this));

    $("#LogScrollBar").mousedown($.proxy(this.startLogScrollbar, this));

    $("#LogContents").scroll($.proxy(this.handleLogScrolled, this));

    $("#LogsTable_length").change($.proxy(this.resizeLogsPage, this));

    this.currentLog = null;
};

LogsTab.prototype.getInitialSort = function()
{
    return [[2, "desc"]];
};

LogsTab.prototype.getColumns = function()
{
    return [
               {
                   title:  "Path",
                   width:  "380px",
                   render: Format.formatStringCleansed
               },
               {
                   title:     "Size",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Last Modified",
                   width:  "170px",
                   render: Format.formatString
               }
           ];
};

LogsTab.prototype.clickHandler = function()
{
    var selected = $("#LogsTable").DataTable().rows({ selected: true }).data();

    if (selected.length > 0)
    {
        var logFile = selected[0][3];

        if (this.refreshing)
        {
            this.retrieveLog(logFile.path, this.currentLog.start, false, true);
        }
        else
        {
            this.retrieveLog(logFile.path, -1, true, false);
        }
    }
    else
    {
        if (!this.refreshing)
        {
            $("#LogContainer").hide();

            this.currentLog = null;
        }
    }
};

LogsTab.prototype.retrieveLog = function(logPath, start, forward, refreshing)
{
    var ajaxDeferred = $.ajax({
                                  url:       Constants.URL__LOG + "?path=" + logPath + "&start=" + start,
                                  dataType: "json"
                              });

    ajaxDeferred.done($.proxy(function(log, status)
                              {
                                  this.handleLogRetrievedSuccessfully(log, forward, refreshing);
                              },
                              this));

    ajaxDeferred.fail(function(xhr, status, error)
                      {
                          AdminUI.showModalDialogError("Error retrieving the log:<br/><br/>" + error);
                      });
};

LogsTab.prototype.handleLogRetrievedSuccessfully = function(log, forward, refreshing)
{
    // log = {path, start, page_size, file_size, data}
    this.currentLog = log;

    $("#LogContents").text(log.data);

    $("#LogLink").text(log.path);
    $("#LogLink").attr("href", "download?path=" + log.path);

    $("#LogContainer").show();

    this.resize();

    if (refreshing)
    {
        $("#LogContents").scrollTop(this.currentLog.scrollTop);
        //$("#LogContents").scrollLeft(this.currentLog.scrollLeft);
    }
    else
    {
        var scrollTop  = 0;

        if ((forward) || (this.currentLog.last == null))
        {
            scrollTop = $("#LogContents")[0].scrollHeight;
        }

        $("#LogContents").scrollTop(scrollTop);
    }
};

LogsTab.prototype.initializeLogButton = function(type)
{
    var upperCaseType = type.charAt(0).toUpperCase() + type.slice(1);

    var imageSuffix = "";

    if (this.currentLog[type] == null)
    {
        imageSuffix = "_disabled";

        $("#Log" + upperCaseType + "Button").addClass("logButtonDisabled");
    }
    else
    {
        $("#Log" + upperCaseType + "Button").removeClass("logButtonDisabled");
    }

    $("#Log" + upperCaseType + "ButtonImage").attr("src", "images/" + type + imageSuffix + ".png");
};

LogsTab.prototype.handleLogFirstClicked = function()
{
    if (!$("#LogFirstButton").hasClass("logButtonDisabled"))
    {
        this.retrieveLog(this.currentLog.path, this.currentLog.first, false, false);
    }
};

LogsTab.prototype.handleLogBackClicked = function()
{
    if (!$("#LogBackButton").hasClass("logButtonDisabled"))
    {
        this.retrieveLog(this.currentLog.path, this.currentLog.back, false, false);
    }
};

LogsTab.prototype.handleLogForwardClicked = function()
{
    if (!$("#LogForwardButton").hasClass("logButtonDisabled"))
    {
        this.retrieveLog(this.currentLog.path, this.currentLog.forward, true, false);
    }
};

LogsTab.prototype.handleLogLastClicked = function()
{
    if (!$("#LogLastButton").hasClass("logButtonDisabled"))
    {
        this.retrieveLog(this.currentLog.path, this.currentLog.last, true, false);
    }
};

LogsTab.prototype.handleLogScrolled = function()
{
    this.currentLog.scrollTop = $("#LogContents").scrollTop();
};

LogsTab.prototype.startLogScrollbar= function(e)
{
    this.dragObject = e.target;

    e = this.fixEvent(e);
    this.dragObject.lastMouseX = e.clientX;

    document.onmousemove = $.proxy(this.dragLogScrollbar, this);
    document.onmouseup   = $.proxy(this.stopLogScrollbar, this);

    return false;
};

LogsTab.prototype.fixEvent = function(e)
{
   if (typeof e == "undefined")
   {
       e = window.event;
   }

   if (typeof e.layerX == "undefined")
   {
       e.layerX = e.offsetX;
   }

   return e;
};

LogsTab.prototype.dragLogScrollbar = function(e)
{
   e = this.fixEvent(e);

   var mouseX = e.clientX;
   var diffX = mouseX - this.dragObject.lastMouseX;

   var containerWidth = $("#LogScrollBarContainer").width();
   var scrollbarWidth = $("#LogScrollBar").width();

   var newX = parseInt(this.dragObject.style.left) + diffX;

   newX = Math.max(newX, 0);
   newX = Math.min(newX, containerWidth - scrollbarWidth);

   this.dragObject.style.left = newX + "px";

   this.dragObject.lastMouseX = mouseX;
   this.dragObject.lastDiffX  = diffX;
};

LogsTab.prototype.stopLogScrollbar = function()
{
   var forward = this.dragObject.lastDiffX > 0;

   var containerWidth = $("#LogScrollBarContainer").width();
   var scrollbarLeft  = parseInt(this.dragObject.style.left);

   var start = Math.round((scrollbarLeft * this.currentLog.file_size) / containerWidth);

   this.retrieveLog(this.currentLog.path, start, forward, false);

   document.onmousemove = null;
   document.onmouseup   = null;

   this.dragObject = null;
};

LogsTab.prototype.resize = function()
{
    var windowHeight = $(window).height();

    var tablePosition = $("#LogsTableContainer").offset();
    var tableHeight   = $("#LogsTableContainer").outerHeight(true);

    var height = windowHeight - tablePosition.top - tableHeight - 60;

    $("#LogContents").height(Math.max(height, 300));


    if (this.currentLog != null)
    {
        this.initializeLogButton("first");
        this.initializeLogButton("back");
        this.initializeLogButton("forward");
        this.initializeLogButton("last");

        var fileSize = this.currentLog.file_size;
        var readSize = this.currentLog.read_size;
        var start    = this.currentLog.start;


        var containerWidth = $("#LogScrollBarContainer").width();

        var left  = 0;
        var width = containerWidth;

        if (fileSize > 0)
        {
            left  = Math.round((containerWidth *    start) / fileSize);
            width = Math.round((containerWidth * readSize) / fileSize);

            width = Math.max(width, 10);
            left  = Math.min(left,  (containerWidth - width));
        }

        $("#LogScrollBar").css({
                                   left:  left  + "px",
                                   width: width + "px"
                               });
    }
};
