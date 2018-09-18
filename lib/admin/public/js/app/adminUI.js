
$(document).ready(function()
{
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
        $(window).resize(AdminUI.resize);

        $(".cloudControllerText").text(AdminUI.settings.cloud_controller_uri);

        if (AdminUI.settings.name)
        {
            $(".name").text(AdminUI.settings.name);
            $(".name").show();
        }
        else
        {
            $(".name").hide();
        }

        if (AdminUI.settings.build)
        {
            $(".build").text("Build " + AdminUI.settings.build);
            $(".build").show();
        }
        else
        {
            $(".build").hide();
        }

        if (AdminUI.settings.api_version)
        {
            $(".apiVersion").text("API Version " + AdminUI.settings.api_version);
            $(".apiVersion").show();
        }
        else
        {
            $(".apiVersion").hide();
        }

        if (AdminUI.settings.uaa_version)
        {
            $(".uaaVersion").text("UAA Version " + AdminUI.settings.uaa_version);
            $(".uaaVersion").show();
        }
        else
        {
            $(".uaaVersion").hide();
        }

        if (AdminUI.settings.osbapi_version)
        {
            $(".osbapiVersion").text("OSB API Version " + AdminUI.settings.osbapi_version);
            $(".osbapiVersion").show();
        }
        else
        {
            $(".osbapiVersion").hide();
        }

        if (AdminUI.settings.user)
        {
            $(".user").text(Format.removeScriptInjection(AdminUI.settings.user));
        }

        this.positionMenuBarComponents(0);
        this.setContentHeight();

        $('[class*="user"]').mouseover(AdminUI.showUserMenu);
        $('[class*="user"]').mouseout(function() { $(".userMenu").hide(); });

        $(".userMenu").click(function() { AdminUI.logout(); });

        $("#MenuButtonLeft").click(AdminUI.handleMenuButtonLeftClicked);
        $("#MenuButtonRight").click(AdminUI.handleMenuButtonRightClicked);

        $("#MenuButtonRefresh").click(AdminUI.handleMenuButtonRefreshClicked);

        $(".menuItem").mouseover(function() { $(this).toggleClass("menuItemHighlighted"); });
        $(".menuItem").mouseout(function()  { $(this).toggleClass("menuItemHighlighted"); });

        $(".menuItem").click(function() { AdminUI.handleTabClicked($(this).attr("id")); });

        var tabIDs = this.getTabIDs();

        this.showLoadingPage();

        this.errorTable = Table.createTable("ModalDialogContents", this.getModalDialogErrorTableColumns(), [], null, null, Constants.FILENAME__ERRORS, null, null);

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
                                                        null,
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
                       title:  "Label",
                       width:  "100px",
                       render: Format.formatString
                   },
                   {
                       title:     "HTTP Status",
                       width:     "70px",
                       className: "cellRightAlign",
                       render:    Format.formatNumber
                   },
                   {
                       title:     "Status Code",
                       width:     "70px",
                       className: "cellRightAlign",
                       render:    Format.formatNumber
                   },
                   {
                       title:  "Status Text",
                       width:  "100px",
                       render: Format.formatString
                   },
                   {
                       title: "Message",
                       width: "100px",
                       render: Format.formatString
                   }
               ];
    },

    getScrollLeftForSelectedMenuItem: function(pageID)
    {
        var menuItem      = $("#" + pageID);
        var menuItemLeft  = menuItem.position().left;
        var menuItemWidth = menuItem.outerWidth();

        var menuItemContainer           = $("#MenuItemContainer");
        var menuItemContainerScrollLeft = menuItemContainer.scrollLeft();
        var menuItemContainerWidth      = menuItemContainer.width();

        var scrollLeft = menuItemContainerScrollLeft;

        if (menuItemLeft < 0)
        {
            scrollLeft = menuItemContainerScrollLeft + menuItemLeft;
        }
        else if ((menuItemLeft + menuItemWidth) > menuItemContainerWidth)
        {
            scrollLeft = menuItemContainerScrollLeft + menuItemLeft + menuItemWidth - menuItemContainerWidth;
        }

        return scrollLeft;
    },

    getTabIDs: function()
    {
        var ids = [];

        $('[class="menuItem"]').each(function(index, value) { ids.push(this.id); });

        return ids;
    },

    handleMenuButtonLeftClicked: function()
    {
        if (!$("#MenuButtonLeft").hasClass("menuButtonDisabled"))
        {
            var menuItemContainer = $("#MenuItemContainer");
            var delta             = Math.min(menuItemContainer.width() / 2, 500);
            var oldScrollLeft     = menuItemContainer.scrollLeft();
            var scrollLeft        = Math.max(0, oldScrollLeft - delta);

            AdminUI.scrollMenuItemContainer(scrollLeft);
        }
    },

    handleMenuButtonRefreshClicked: function()
    {
        AdminUI.refresh();
    },

    handleMenuButtonRightClicked: function()
    {
        if (!$("#MenuButtonRight").hasClass("menuButtonDisabled"))
        {
            var menuItemContainer = $("#MenuItemContainer");
            var delta             = Math.min(menuItemContainer.width() / 2, 500);
            var oldScrollLeft     = menuItemContainer.scrollLeft();
            var scrollLeft        = oldScrollLeft + delta;

            AdminUI.scrollMenuItemContainer(scrollLeft);
        }
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

        AdminUI.restoreCursor();
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

    positionMenuBarComponents: function(scrollLeft)
    {
        var menuBar           = $("#MenuBar");
        var menuButtonLeft    = $("#MenuButtonLeft");
        var menuButtonRight   = $("#MenuButtonRight");
        var menuButtonRefresh = $("#MenuButtonRefresh");
        var menuItemContainer = $("#MenuItemContainer");

        var lastChild = menuItemContainer.children().last();
        var menuItemContainerPosition = menuItemContainer.position();

        var newMenuItemContainerWidth = Math.min(menuBar.width() - (menuButtonLeft.outerWidth() + menuButtonRight.outerWidth() + menuButtonRefresh.outerWidth()),
                                                 lastChild.position().left + lastChild.outerWidth() + scrollLeft);

        $(".menuItemContainer").css({
                                        width: newMenuItemContainerWidth + "px"
                                    });

        $(".menuButtonRight").css({
                                      left: menuItemContainerPosition.left + newMenuItemContainerWidth + "px"
                                  });

        $(".menuButtonRefresh").css({
                                        left: menuItemContainerPosition.left + newMenuItemContainerWidth + menuButtonRight.width() + "px"
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

    removeAllDopplerItemsConfirmation: function()
    {
        AdminUI.showModalDialogConfirmation("Are you sure you want to remove all OFFLINE doppler components?",
                                            "Remove",
                                            function() { AdminUI.removeItem(true, null); });
    },

    removeAllVarzItemsConfirmation: function()
    {
        AdminUI.showModalDialogConfirmation("Are you sure you want to remove all OFFLINE varz components?",
                                            "Remove",
                                            function() { AdminUI.removeItem(false, null); });
    },

    removeItem: function(doppler, uri)
    {
        AdminUI.showModalDialogProgress("Removing Offline Components");

        var removeURI = doppler ? Constants.URL__DOPPLER_COMPONENTS : Constants.URL__COMPONENTS;

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

                          $("#" + type + "Table").DataTable().rows().deselect();

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

    removeItemConfirmation: function(doppler, uri)
    {
        AdminUI.showModalDialogConfirmation("Are you sure you want to remove " + uri + "?",
                                            "Remove",
                                            function() { AdminUI.removeItem(doppler, uri); });
    },

    resize: function()
    {
        AdminUI.setContentHeight();

        var pageID = AdminUI.getCurrentPageID();

        var scrollLeft = AdminUI.getScrollLeftForSelectedMenuItem(pageID);

        AdminUI.positionMenuBarComponents(scrollLeft);
        AdminUI.scrollMenuItemContainer(scrollLeft);

        if (AdminUI.tabs[pageID].resize)
        {
            AdminUI.tabs[pageID].resize();
        }
    },

    restoreCursor: function()
    {
        $("html").removeClass("waiting");

        // The cursor does not change on the Application's page.
        // Interestingly, simply calling this fixes the issue.
        $("#MenuButtonRefresh").css("left");
    },

    scrollMenuItemContainer: function(scrollLeft)
    {
        var menuButtonLeft    = $("#MenuButtonLeft");
        var menuButtonRight   = $("#MenuButtonRight");
        var menuItemContainer = $("#MenuItemContainer");

        if (scrollLeft == 0)
        {
            menuButtonLeft.addClass("menuButtonDisabled");
            menuButtonLeft.attr("src", "images/back_disabled.png");
        }
        else
        {
            menuButtonLeft.removeClass("menuButtonDisabled");
            menuButtonLeft.attr("src", "images/back.png");
        }

        if (scrollLeft + menuItemContainer.outerWidth() >= menuItemContainer.prop('scrollWidth'))
        {
            menuButtonRight.addClass("menuButtonDisabled");
            menuButtonRight.attr("src", "images/forward_disabled.png");
        }
        else
        {
            menuButtonRight.removeClass("menuButtonDisabled");
            menuButtonRight.attr("src", "images/forward.png");
        }

        menuItemContainer.scrollLeft(scrollLeft);
    },

    setContentHeight: function()
    {
        var contentHeight = $(window).height() - $("#Content").position().top;

        $(".content").css({
                              height: contentHeight + "px"
                          });
    },

    /**
     * This function shows the specified tab as selected but does not show the
     * tab contents. The selected tab will show its contents when it has
     * finished updating.
     */
    setTabSelected: function(pageID)
    {
        // Hide all of the tab pages.
        $("*[id*=Page]").each(function() { $(this).addClass("hiddenPage"); });

        // Select the tab.
        $(".menuItem").removeClass("menuItemSelected");
        $("#" + pageID).addClass("menuItemSelected");

        AdminUI.scrollMenuItemContainer(AdminUI.getScrollLeftForSelectedMenuItem(pageID));
    },

    showApplicationInstances: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__APPLICATION_INSTANCES, filter);
    },

    showApplications: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__APPLICATIONS, filter);
    },

    showApprovals: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__APPROVALS, filter);
    },

    showBuildpacks: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__BUILDPACKS, filter);
    },

    showCells: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__CELLS, filter);
    },

    showClients: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__CLIENTS, filter);
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

    showEvents: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__EVENTS, filter);
    },

    showGroupMembers: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__GROUP_MEMBERS, filter);
    },

    showGroups: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__GROUPS, filter);
    },

    showIdentityProviders: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__IDENTITY_PROVIDERS, filter);
    },

    showIdentityZones: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__IDENTITY_ZONES, filter);
    },

    showIsolationSegments: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ISOLATION_SEGMENTS, filter);
    },

    showLoadingPage: function()
    {
        AdminUI.loading = true;

        $(".loadingPage").show();
    },

    showMFAProviders: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__MFA_PROVIDERS, filter);
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
                var button            = buttons[buttonIndex];
                var buttonID          = "modalDialogButton" + buttonIndex;
                var modalDialogButton = $("<button " + 'id="' + buttonID + '" class="modalDialogButton">' + button.name + "</button>");

                modalDialogButton.click(button.callback);

                if (button.keyupField != null)
                {
                    // Need closure so the value of buttonID is not the last value from the buttons loop
                    (function(keyUpButtonID)
                    {
                        $("#" + button.keyupField).keyup(function(event)
                                                         {
                                                             if(event.keyCode == 13)
                                                             {
                                                                 $("#" + keyUpButtonID).click();
                                                             }
                                                         });
                    })(buttonID);
                }

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
            // Have to show the table prior to populating for its sizing to work correctly.
            $("#ModalDialogContentsTableContainer").show();

            var api = this.errorTable.api();

            api.clear().rows.add(tableData).draw();

            api.buttons.resize();
        }
        else
        {
            $("#ModalDialogContentsTableContainer").hide();
        }

        $("#ModalDialogBackground").removeClass("hiddenPage");
        $("#ModalDialog").removeClass("hiddenPage");
    },

    showModalDialogAction: function(title, content, okButtonText, okButtonKeyupField, okButtonCallback)
    {
        AdminUI.showModalDialog(title,
                                content,
                                null,
                                [
                                    {
                                      name:       okButtonText,
                                      keyupField: okButtonKeyupField,
                                      callback:   okButtonCallback,
                                    },
                                    {
                                        name:       "Cancel",
                                        keyupField: null,
                                        callback:   function() { AdminUI.hideModalDialog(); }
                                    }
                                ]);
    },

    showModalDialogConfirmation: function(text, okButtonText, okButtonCallback)
    {
        AdminUI.showModalDialogAction("Confirmation",
                                      $("<label>" + text + "</label>"),
                                      okButtonText,
                                      null,
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
                                        name:       "Close",
                                        keyupField: null,
                                        callback:   function() { AdminUI.hideModalDialog(); }
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
                                        name:       "Close",
                                        keyupField: null,
                                        callback:   function() { AdminUI.hideModalDialog(); }
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
                                        name:       "Close",
                                        keyupField: null,
                                        callback:   function() { AdminUI.hideModalDialog(); }
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

    showOrganizationsIsolationSegments: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ORGANIZATIONS_ISOLATION_SEGMENTS, filter);
    },

    showQuotas: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__QUOTA_DEFINITIONS, filter);
    },

    showRevocableTokens: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__REVOCABLE_TOKENS, filter);
    },

    showRouteBindings: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ROUTE_BINDINGS, filter);
    },

    showRouteMappings: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ROUTE_MAPPINGS, filter);
    },

    showRoutes: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__ROUTES, filter);
    },

    showSecurityGroups: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SECURITY_GROUPS, filter);
    },

    showSecurityGroupsSpaces: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SECURITY_GROUPS_SPACES, filter);
    },

    showServiceBindings: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_BINDINGS, filter);
    },

    showServiceBrokers: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_BROKERS, filter);
    },

    showServiceInstances: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_INSTANCES, filter);
    },

    showServiceKeys: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_KEYS, filter);
    },

    showServicePlans: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_PLANS, filter);
    },

    showServicePlanVisibilities: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_PLAN_VISIBILITIES, filter);
    },

    showServiceProviders: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICE_PROVIDERS, filter);
    },

    showServices: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SERVICES, filter);
    },

    showSharedServiceInstances: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SHARED_SERVICE_INSTANCES, filter);
    },

    showSpaceQuotas: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SPACE_QUOTA_DEFINITIONS, filter);
    },

    showSpaceRoles: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SPACE_ROLES, filter);
    },

    showSpaces: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__SPACES, filter);
    },

    showStacks: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__STACKS, filter);
    },

    showStagingSecurityGroupsSpaces: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__STAGING_SECURITY_GROUPS_SPACES, filter);
    },

    showTabFiltered: function(pageID, filter)
    {
        Table.saveSelectedTableRowVisible();

        AdminUI.setTabSelected(pageID);

        AdminUI.tabs[pageID].showFiltered(filter);
    },

    showTasks: function(filter)
    {
        AdminUI.showTabFiltered(Constants.ID__TASKS, filter);
    },

    showUserMenu: function()
    {
        var position = $(".userContainer").position();

        var height = $(".userContainer").outerHeight();
        var width  = $(".userContainer").outerWidth();

        var menuWidth = $(".userMenu").outerWidth();

        $(".userMenu").css({
                               position: "absolute",
                               top:      (position.top + height + 2) + "px",
                               left:     (position.left + width - menuWidth) + "px"
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
