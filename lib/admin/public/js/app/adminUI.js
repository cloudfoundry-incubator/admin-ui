
$(function()
{
    // I need to upload error information that will be displayed in AdminUI
    AppI18n.init();
    // start Admin UI client application
    AdminUI.startup();
});

var AdminUI =
{
    tabs: [],

    startup: function()
    {
        AdminUI.loading = false;
        
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
            window.location.href = Constants.URL__LOGIN;
        });        
    },

    initialize: function()
    {
        AdminUI.user = decodeURIComponent((new RegExp('[?|&]user=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;

        $(window).resize(AdminUI.resize);

        if (AdminUI.settings.admin)
        {
            $("#Tasks").removeClass("hiddenPage");
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

        var tabIDs = this.getTabIDs();
        
        this.showLoadingPage();
        
        try
        {
            $(tabIDs).each(function(index, tabID)
            {
                if (window[tabID + "Tab"])
                {
                    AdminUI.tabs[tabID] = new window[tabID + "Tab"](tabID);
                    AdminUI.tabs[tabID].initialize();
                }
            });
        }
        finally
        {
            AdminUI.hideLoadingPage();
        }

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

        this.tabs[pageID].refresh();
    },

    hideDialog: function()
    {
        $("#Dialog").addClass("hiddenPage");
    },
    
    hideErrorPage: function()
    {
        $(".errorPage").hide();
    },
    
    hideLoadingPage: function()
    {
        AdminUI.loading = false;
        
        $(".loadingPage").hide();
    },

    logout: function()
    {
        var deferred = $.ajax({
                                  url: Constants.URL__LOGOUT,
                                  dataType: "json",
                                  type: "GET"
                              });

        deferred.done(function(result, status)
        {
            if (result.redirect)
            {
                window.location.href = result.redirect;
            }
        });
    },

    refresh: function()
    {
        Table.saveSelectedTableRowVisible();

        var pageID = AdminUI.getCurrentPageID();
        
        AdminUI.showWaitCursor();

        try
        {
            AdminUI.tabs[pageID].refresh();
        }
        finally
        {
            AdminUI.restoreCursor();
        }
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
                                  type: "DELETE",
                                  "async": false
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
        
        deferred.always(function()
        {
            AdminUI.restoreCursor();
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
        AdminUI.showTabFiltered(Constants.ID__APPLICATIONS, filter);
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

    showDEAs: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__DEAS, filter);
    },
    
    showDomains: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__DOMAINS, filter);
    },

    showErrorPage: function(error)
    {
        if (!AdminUI.loading)
        {
            $(".errorText").text(error);
            $(".errorPage").show();
        }
    },
    
    showTabFiltered: function(pageID, filter)
    {
        Table.saveSelectedTableRowVisible();

        AdminUI.setTabSelected(pageID);
        
        AdminUI.tabs[pageID].showFiltered(filter);
    },

    showLoadingPage: function()
    {
        AdminUI.loading = true;
        
        $(".loadingPage").show();
    },

    showOrganizationRoles: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ORGANIZATION_ROLES, filter);
    },

    showOrganizations: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ORGANIZATIONS, filter);
    },

    showQuotas: function(quotaName)
    {
        AdminUI.showTabFiltered(Constants.ID__QUOTA_DEFINITIONS, quotaName);
    },

    showRoutes: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ROUTES, filter);
    },

    showServiceInstances: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_INSTANCES, filter);
    },

    showServicePlans: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_PLANS, filter);
    },

    showSpaceRoles: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SPACE_ROLES, filter);
    },

    showSpaces: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SPACES, filter);
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
    
    showUsers: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__USERS, filter);
    },

    showWaitCursor: function()
    {   
        $("html").addClass("waiting");
    },

    showContent: function(id)
    {
        $(id).css(
            {
                'display': 'block'
            }
        );
    },

    hideContent: function(id)
    {
        $(id).css(
            {
                'display': 'none'
            }
        );
    },

    showModalDialog: function(dialog)
    {
        if (!dialog)
        {
            return;
        }

        if (!dialog.height || !parseInt(dialog.height))
        {
            dialog.height = 50;
        }

        if (!dialog.width || !parseInt(dialog.width))
        {
            dialog.width = 280;
        }

        if (dialog.title)
        {
            AdminUI.showContent('#ModalDialogTitleDiv');
            $('#ModalDialogTitleDiv')[0].innerHTML = dialog.title;
        }
        else
        {
            AdminUI.hideContent('#ModalDialogTitleDiv');
        }

        if (dialog.buttons && dialog.buttons.length > 0)
        {
            $('#ModalDialogButtonsDiv').empty();
            AdminUI.showContent('#ModalDialogButtonsDiv');
            AdminUI.showContent('#ModalDialogButtonsLine');

            for (var step = 0; step < dialog.buttons.length; step ++)
            {
                var button = $("<button " + 'id="modalDialogButton' + step + '">' + dialog.buttons[step].name +  "</button>");
                button.click(dialog.buttons[step].callback);
                button.appendTo($('#ModalDialogButtonsDiv'));
            }
        }
        else
        {
            AdminUI.hideContent('#ModalDialogButtonsDiv');
            AdminUI.hideContent('#ModalDialogButtonsLine');
        }

        if (dialog.body)
        {
            $('#ModalDialogMessageDiv').empty();
            $('#ModalDialogMessageDiv').append(dialog.body);
            AdminUI.showContent('#ModalDialogMessageDiv');
        }
        else
        {
            AdminUI.hideContent('#ModalDialogMessageDiv');
        }

        $('#ModalDialogDiv').width(dialog.width + 'px');
        $('#ModalDialogDiv').css({ 'marginLeft': '-' + dialog.width/2 + 'px' });
        $('#ModalDialogMessageDiv').width(dialog.width + 'px');
        $('#ModalDialogMessageDiv').height(dialog.height + 'px');

        AdminUI.showContent('#ModalDialogBackgroundDiv');
        AdminUI.showContent('#ModalDialogDiv');
    },

    closeModalDialog: function()
    {
        AdminUI.hideContent("#ModalDialogDiv");
        AdminUI.hideContent("#ModalDialogBackgroundDiv");
    }
};

