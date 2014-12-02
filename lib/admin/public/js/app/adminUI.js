
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
                                  url:      Constants.URL__SETTINGS,
                                  dataType: "json",
                                  type:     "GET"
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

        $(".menuItem").mouseover(function() { $(this).toggleClass("menuItemHighlighted"); });
        $(".menuItem").mouseout(function()  { $(this).toggleClass("menuItemHighlighted"); });

        $(".menuItem").click(function() { AdminUI.handleTabClicked($(this).attr("id")); });

        var tabIDs = this.getTabIDs();
        
        this.showLoadingPage();
        
        this.errorTable = Table.createTable("ModalDialogContents", this.getModalDialogErrorTableColumns(), [], null, null, null, null);
        
        $("#ModalDialogContentsTableContainer").hide();
        
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
        AdminUI.showModalDialogProgress("Starting DEA Task");
        
        var deferred = $.ajax({
                                  url:      Constants.URL__DEAS,
                                  dataType: "json",
                                  type:     "POST"
                              });

        deferred.done(function(response, status)
        {  
            AdminUI.showModalDialogSuccess(); 
        });
        
        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showModalDialogError("Error starting the task:<br/><br/>" + error);
        });
    },

    createDEAConfirmation: function()
    {
        AdminUI.showModalDialogConfirmation("Are you sure you want to create a new DEA?", 
                                            "Create",
                                            AdminUI.createDEA);
    },

    createStats: function(stats)
    {
        AdminUI.showModalDialogProgress("Creating statistics");
        
        var deferred = $.ajax({
                                  url:      Constants.URL__STATS,
                                  dataType: "json",
                                  type:     "POST",
                                  data:     stats
                              });

        deferred.done(function(response, status)
        {
            AdminUI.showModalDialogSuccess();
            
            AdminUI.refresh();
        });

        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showModalDialogError("Error saving statistics:<br/><br/>" + error);
        });
    },

    createStatsConfirmation: function()
    {
        var deferred = $.ajax({
                                  url:      Constants.URL__CURRENT_STATS,
                                  dataType: "json",
                                  type:     "GET"
                              });

        deferred.done(function(stats, status)
        {            
            var statsView = AdminUI.tabs[Constants.ID__STATS].buildCurrentStatsView(stats);

            AdminUI.showModalDialogAction("Confirmation",
                                          statsView, 
                                          "Create",
                                          function() { AdminUI.createStats(stats); });
        });

        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showModalDialogError("Error generating statistics:<br/><br/>" + error);
        });   
    },

    getCurrentPageID: function()
    {
        return $($.find(".menuItemSelected")).attr("id");
    },
    
    getModalDialogErrorTableColumns: function()
    {
        return [
                   {
                       "sTitle":  "Label",
                       "sWidth":  "100px"
                   },
                   {
                       "sTitle":  "HTTP Status",
                       "sWidth":  "70px",
                       "sClass":  "cellRightAlign",
                       "mRender": Format.formatNumber
                   },
                   {
                       "sTitle":  "Status Code",
                       "sWidth":  "70px",
                       "sClass":  "cellRightAlign",
                       "mRender": Format.formatNumber
                   },
                   {
                       "sTitle":  "Status Text",
                       "sWidth":  "100px"
                   },
                   {
                       "sTitle":  "Message",
                       "sWidth":  "100px"
                   }
               ];
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

    hideErrorPage: function()
    {
        $(".errorPage").hide();
    },
    
    hideLoadingPage: function()
    {
        AdminUI.loading = false;
        
        $(".loadingPage").hide();
    },

    hideModalDialog: function()
    {
        $("#ModalDialogContentsSimple").addClass("hiddenPage");
        $("#ModalDialogContentsTableContainer").hide();
        $("#ModalDialog").addClass("hiddenPage");
        $("#ModalDialogBackground").addClass("hiddenPage");
    },

    logout: function()
    {
        var deferred = $.ajax({
                                  url:      Constants.URL__LOGOUT,
                                  dataType: "json",
                                  type:     "GET"
                              });

        deferred.done(function(result, status)
        {
            if (result.redirect)
            {
                window.location.href = result.redirect;
            }
        });
        
        deferred.fail(function(xhr, status, error)
        {
            AdminUI.showModalDialogError("Error logging out:<br/><br/>" + error);
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
        AdminUI.showModalDialogConfirmation("Are you sure you want to remove all OFFLINE components?", 
                                            "Remove",
                                            function() { AdminUI.removeItem(null); });
    },

    removeItem: function(uri)
    {
        AdminUI.showModalDialogProgress("Removing Offline Components");

        var removeURI = Constants.URL__COMPONENTS;

        if (uri != null)
        {
            removeURI += "?uri=" + encodeURIComponent(uri); 
        }

        var deferred = $.ajax({
                                  url:      removeURI,
                                  dataType: "json",
                                  type:     "DELETE"
                              });

        deferred.done(function(response, status)
        {            
            AdminUI.showModalDialogSuccess();
            
            var type = AdminUI.getCurrentPageID();

            var tableTools = TableTools.fnGetInstance(type + "Table");

            tableTools.fnSelectNone();

            AdminUI.refresh(); 
        });

        deferred.fail(function(xhr, status, error)
        {
            var errorMessage = "Error removing ";

            if (uri != null)
            {
                errorMessage += uri;
            }
            else
            {
                errorMessage += "all components";
            }

            AdminUI.showModalDialogError(errorMessage + ":<br/><br/>" + error);
        });
    },

    removeItemConfirmation: function(uri)
    {
        AdminUI.showModalDialogConfirmation("Are you sure you want to remove " + uri + "?",
                                            "Remove",
                                            function()
                                            {
                                                AdminUI.removeItem(uri);
                                            });
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
    
    showLoadingPage: function()
    {
        AdminUI.loading = true;
        
        $(".loadingPage").show();
    },

    showModalDialog: function(title, content, tableData, buttons)
    {
        $("#ModalDialogTitle").text(title);
        
        $("#ModalDialogContentsSimple").empty();
        
        if (content != null)
        {
            $("#ModalDialogContentsSimple").append(content);
            $("#ModalDialogContentsSimple").removeClass("hiddenPage");
        }
        else
        {
            $("#ModalDialogContentsSimple").addClass("hiddenPage");
        }
        
        $("#ModalDialogButtonContainer").empty();

        if ((buttons != null) && (buttons.length > 0))
        {
            for (var buttonIndex = 0; buttonIndex < buttons.length; buttonIndex++)
            {
                var button = buttons[buttonIndex];
                
                var modalDialogButton = $("<button " + 'id="modalDialogButton' + buttonIndex + '" class="modalDialogButton">' + button.name + "</button>");
                modalDialogButton.click(button.callback);
                modalDialogButton.appendTo($("#ModalDialogButtonContainer"));
            }
            
            $("#ModalDialogButtonContainer").removeClass("hiddenPage");
        }
        else
        {
            $("#ModalDialogButtonContainer").addClass("hiddenPage");
        }

        var windowHeight = $(window).height();
        var windowWidth  = $(window).width();

        $("#ModalDialog").css("top",  windowHeight / 8);
        $("#ModalDialog").css("left", windowWidth  / 8);

        if (tableData != null)
        {
            var tableTools = TableTools.fnGetInstance("ModalDialogContentsTable");
            if ((tableTools != null) && tableTools.fnResizeRequired())
            {
                tableTools.fnResizeButtons();
            }
            
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ModalDialogContentsTableContainer").show();
            
            this.errorTable.fnClearTable();
            this.errorTable.fnAddData(tableData);
        }
        else
        {
            $("#ModalDialogContentsTableContainer").hide();
        }
        
        $("#ModalDialogBackground").removeClass("hiddenPage");
        $("#ModalDialog").removeClass("hiddenPage");
    },
    
    showModalDialogAction: function(title, content, okButtonText, okButtonCallback)
    {
        AdminUI.showModalDialog(title, 
                                content,
                                null,
                                [
                                    {
                                      "name":     okButtonText,
                                      "callback": okButtonCallback
                                    },
                                    {
                                        "name":     "Cancel",
                                        "callback": function()
                                        {
                                            AdminUI.hideModalDialog();
                                        }
                                    }
                                ]);
    },
    
    showModalDialogConfirmation: function(text, okButtonText, okButtonCallback)
    {
        AdminUI.showModalDialogAction("Confirmation",
                                      $("<label>" + text + "</label>"),
                                      okButtonText,
                                      okButtonCallback);
    },
    
    showModalDialogError: function(text)
    {
        AdminUI.restoreCursor();

        AdminUI.showModalDialog("Error", 
                                $("<label>" + text + "</label>"),
                                null,
                                [
                                    {
                                        "name":     "Close",
                                        "callback": function()
                                        {
                                            AdminUI.hideModalDialog();
                                        }
                                    }
                                ]);
    },
    
    showModalDialogErrorTable: function(inputs)
    {
        var tableData = [];

        for (var inputIndex = 0; inputIndex < inputs.length; inputIndex++)
        {
            var input = inputs[inputIndex];
            var label = input.label;
            var xhr   = input.xhr;

            var row = [];
            
            row.push(label);
            row.push(xhr.status);
            
            if (xhr.responseText != null)
            {
                try
                {
                    var parsed = jQuery.parseJSON(xhr.responseText);
                    
                    if (parsed.cf_code != null)
                    {
                        row.push(parsed.cf_code);
                    }
                    else
                    {
                        Utilities.addEmptyElementsToArray(row, 1);
                    }
                    
                    if (parsed.cf_error_code != null)
                    {
                        row.push(parsed.cf_error_code);
                    }
                    else
                    {
                        Utilities.addEmptyElementsToArray(row, 1);
                    }
                    
                    if (parsed.message != null)
                    {
                        row.push(parsed.message);
                    }
                    else
                    {
                        Utilities.addEmptyElementsToArray(row, 1);
                    }
                }
                catch (error) 
                {
                    Utilities.addEmptyElementsToArray(row, 3);
                }
            }
            
            tableData.push(row);
        }

        AdminUI.restoreCursor();

        AdminUI.showModalDialog("Error", 
                                null,
                                tableData,
                                [
                                    {
                                        "name":     "Close",
                                        "callback": function()
                                        {
                                            AdminUI.hideModalDialog();
                                        }
                                    }
                                ]);
    },
    
    showModalDialogProgress: function(title)
    {
        AdminUI.showWaitCursor();
        
        AdminUI.showModalDialog(title, 
                                $("<label>Performing operation, please wait...</label>"),
                                null,
                                null);
    },
    
    showModalDialogSuccess: function()
    {
        AdminUI.restoreCursor();

        AdminUI.showModalDialog("Success", 
                                $("<label>The operation finished without error. Please refresh the page later for the updated result.</label>"),
                                null,
                                [
                                    {
                                        "name":     "Close",
                                        "callback": function()
                                        {
                                            AdminUI.hideModalDialog();
                                        }
                                    }
                                ]);
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

    showTabFiltered: function(pageID, filter)
    {
        Table.saveSelectedTableRowVisible();

        AdminUI.setTabSelected(pageID);
        
        AdminUI.tabs[pageID].showFiltered(filter);
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
    }
};
