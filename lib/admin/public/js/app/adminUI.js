
$(document).ready(function()
{
    AdminUI.startup();
});

var AdminUI =
{
    tabs: [],

    startup: function()
    {
        var deferred = $.ajax({
                                  url: Constants.URL__SETTINGS,
                                  dataType: "json",
                                  type: "GET"
                              });

        deferred.done(function(response, status)
        {            
            AdminUI.settings = response;

            AdminUI.initialize();
        });

        deferred.fail(function(xhr, status, error)
        {
            window.location.href = "login.html";
        });        
    },

    initialize: function()
    {
        AdminUI.user = decodeURIComponent((new RegExp('[?|&]user=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;

        $(window).resize(AdminUI.resize);

        if (AdminUI.settings.admin)
        {
            $("#Tasks").removeClass("hiddenPage");
            $("#DEAsActions").removeClass("hiddenPage");
            $("#ComponentsActions").removeClass("hiddenPage");
            $("#StatsActions").removeClass("hiddenPage");
        }

        $(".cloudControllerText").text(AdminUI.settings.cloud_controller_uri);
        $(".user").text(AdminUI.user);

        $('[class*="user"]').mouseover(AdminUI.showUserMenu);
        $('[class*="user"]').mouseout(function() { $(".userMenu").hide(); });

        $(".userMenu").click(function() { AdminUI.logout(); });

        $("#RefreshButton").click(AdminUI.refresh);

        $("#DialogCancelButton").click(AdminUI.hideDialog);

        $(".menuItem").mouseover(function() { $(this).toggleClass("menuItemHighlighted"); });
        $(".menuItem").mouseout(function()  { $(this).toggleClass("menuItemHighlighted"); });

        $(".menuItem").click(function() { AdminUI.handleTabClicked($(this).attr("id")); });

        Data.initialize();
        Data.refresh();

        var tabIDs = this.getTabIDs();
        $(tabIDs).each(function(index, tabID)
        {
            if (window[tabID + "Tab"])
            {
                AdminUI.tabs[tabID] = new window[tabID + "Tab"](tabID);
                AdminUI.tabs[tabID].initialize();
            }
        });   

        this.showLoadingPage();

        this.handleTabClicked(Constants.ID__DEAS);
    },


    createDEA: function()
    {
        var deferred = $.ajax({
                                  url: Constants.URL__DEAS,
                                  dataType: "json",
                                  type: "POST"
                              });

        deferred.done(function(response, status)
        {  
            //AdminUI.showDialog("Information", "A task to create a new DEA has been started.");

            AdminUI.hideDialog();
        });

        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showDialog("Error", "There was an error starting the task: <br/><br/>" + error);
        });
    },

    createDEAConfirmation: function()
    {
        AdminUI.showDialog("Confirmation", "Are you sure you want to create a new DEA?", AdminUI.createDEA);
    },

    createStats: function(stats)
    {
        var deferred = $.ajax({
                                  url: Constants.URL__STATS,
                                  dataType: "json",
                                  type: "POST",
                                  data: stats
                              });

        deferred.done(function(response, status)
        {  
            AdminUI.refresh();

            AdminUI.hideDialog();
        });

        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showDialog("Error", "There was an error saving the statistics: <br/><br/>" + error);
        });
    },

    createStatsConfirmation: function()
    {
        var deferred = $.ajax({
                                  url: Constants.URL__CURRENT_STATS,
                                  dataType: "json",
                                  type: "GET"
                              });

        deferred.done(function(stats, status)
        {            
            var dialogText = AdminUI.tabs[Constants.ID__STATS].buildCurrentStatsView(stats);

            AdminUI.showDialog("Confirmation", dialogText, function() { AdminUI.createStats(stats); });
        });

        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showDialog("Information", "The system is unable to generate statistics at this time.<br/><br/>Make sure all Health Managers are online.");
        });   
    },

    getCurrentPageID: function()
    {
        return $($.find(".menuItemSelected")).attr("id");
    },

    getTabIDs: function()
    {
        var ids = [];

        $('[class="menuItem"]').each(function(index, value)
        {
            ids.push(this.id);
        }); 

        return ids;
    },

    handleTabClicked: function(pageID)
    {
        Table.saveSelectedTableRowVisible();

        this.setTabSelected(pageID);

        this.tabs[pageID].refresh(false);
    },

    hideDialog: function()
    {
        $("#Dialog").addClass("hiddenPage");
    },

    logout: function()
    {
        var deferred = $.ajax({
                                  url: Constants.URL__LOGIN,
                                  dataType: "json",
                                  type: "POST"
                              });

        deferred.always(function(xhr, status, error)
        {
            window.location.href = "login.html";
        });
    },

    refresh: function()
    {
        Table.saveSelectedTableRowVisible();

        AdminUI.showWaitCursor();

        $.event.trigger({
                            type: Constants.EVENT__REFRESH,
                	          message: Constants.EVENT__REFRESH,
                	          time: new Date()
                        });

        Data.refresh();

        var pageID = AdminUI.getCurrentPageID();

        AdminUI.tabs[pageID].refresh(false);
    },

    removeAllItemsConfirmation: function()
    {
        AdminUI.showDialog("Confirmation", "Are you sure you want to remove all OFFLINE components?", function() { AdminUI.removeItem(null); });
    },

    removeItem: function(uri)
    {
        AdminUI.showWaitCursor();

        AdminUI.hideDialog();

        var removeURI = Constants.URL__COMPONENTS;

        if (uri != null)
        {
            removeURI += "?uri=" + encodeURIComponent(uri); 
        }

        var deferred = $.ajax({
                                  url: removeURI,
                                  dataType: "json",
                                  type: "DELETE"
                              });

        deferred.done(function(response, status)
        {            
            var type = AdminUI.getCurrentPageID();

            var tableTools = TableTools.fnGetInstance(type + "Table");

            tableTools.fnSelectNone();

            AdminUI.refresh(); 
        });

        deferred.fail(function(xhr, status, error)
        {
            var errorMessage = "There was an error removing ";

            if (uri != null)
            {
                errorMessage += uri;
            }
            else
            {
                errorMessage += "all components";
            }

            AdminUI.showDialog("Error", errorMessage + ": <br/><br/>" + error);
        });
    },

    removeItemConfirmation: function(uri)
    {
        AdminUI.showDialog("Confirmation", "Are you sure you want to remove " + uri + "?", 
                           $.proxy(function()
                           {
                               this.removeItem(uri);
                           },
                           this));
    },

    resize: function()
    {
        $(".menuItemSelected").each(function(index, tab)
        {        
            if (AdminUI.tabs[tab.id].resize)
            {
                AdminUI.tabs[tab.id].resize();
            }
        });        
    },

    restoreCursor: function()
    {
        $("html").removeClass("waiting");

        // The cursor does not change on the Application's page.  
        // Interestingly, simply calling this fixes the issue.
        $("#RefreshButton").css("left");
    },

    /**
     * This function shows the specified tab as selected but does not show the
     * tab contents.  The selected tab will show its contents when it has 
     * finished updating.
     */
    setTabSelected: function(pageID)
    {
        // Hide all of the tab pages.
        $("*[id*=Page]").each(function()
        {
            $(this).addClass("hiddenPage");
        });

        // Select the tab.
        $(".menuItem").removeClass("menuItemSelected");
        $("#" + pageID).addClass("menuItemSelected");
    },

    showApplications: function(filter)
    {
        AdminUI.tabs[Constants.ID__APPLICATIONS].showApplications(filter);
    },

    showDialog: function(title, text, handler)
    {        
        if (handler != null)
        {
            $("#DialogOkayButton").removeClass("hiddenPage");

            $("#DialogOkayButton").off("click.Dialog");
            $("#DialogOkayButton").on("click.Dialog", handler);

            $("#DialogCancelButton").text("Cancel");
        }
        else
        {
            $("#DialogOkayButton").addClass("hiddenPage");


            $("#DialogCancelButton").text("Close");
        }

        var windowHeight = $(window).height();
        var windowWidth  = $(window).width();

        $("#Dialog").css("top",  (windowHeight / 2) - 100);
        $("#Dialog").css("left", (windowWidth  / 2) - 200);

        $("#DialogTitle").text(title);

        $("#DialogText").text("");
        $("#DialogText").append(text);

        $("#Dialog").removeClass("hiddenPage");
    },

    showDEA: function(deaIndex)
    {
        AdminUI.tabs[Constants.ID__DEAS].showDEA(deaIndex);
    },

    showErrorPage: function(error)
    {
        $(".loadingPage").hide();

        $(".errorText").text(error);
        $(".errorPage").show();
    },

    showLoadingPage: function()
    {
        $(".errorPage").hide();
        $(".loadingPage").show();
    },

    showOrganization: function(organizationName)
    {
        AdminUI.tabs[Constants.ID__ORGANIZATIONS].showOrganization(organizationName);
    },

    showSpace: function(target)
    {
        AdminUI.tabs[Constants.ID__SPACES].showSpace(target);
    },

    showSpaces: function(filter)
    {
        AdminUI.tabs[Constants.ID__SPACES].showSpaces(filter);
    },

    showUserMenu: function()
    {
        var position = $(".userContainer").position();

        var height = $(".userContainer").outerHeight();
        var width  = $(".userContainer").outerWidth();

        var menuWidth = $(".userMenu").outerWidth();

        $(".userMenu").css({
                               position: "absolute",
                               top: (position.top + height + 2) + "px",
                               left: (position.left + width - menuWidth) + "px"
                           }).show();
    },

    showDevelopers: function(filter)
    {
        AdminUI.tabs[Constants.ID__DEVELOPERS].showDevelopers(filter);
    },

    showWaitCursor: function()
    {   
        $("html").addClass("waiting");
    }
};

