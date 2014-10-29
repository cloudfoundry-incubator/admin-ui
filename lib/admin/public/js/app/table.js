
var Table =
{
    ignoreScroll: false,  

    tablePageNumbers:        {},
    tableScrollPositions:    {},
    tableSelectedRowVisible: {},

    addClearFilterButton: function(containerID, table)
    {
        var button = document.createElement("img");

        $(button).attr("src", "images/clear.png");

        $(button).css("cursor",         "pointer");
        $(button).css("vertical-align", "middle");
        $(button).css("margin-left",    "5px");

        $(button).click(function()
        {
            table.fnFilter("");
        });

        var filter = $("#" + containerID).find(".dataTables_filter");

        $(filter[0]).append(button);
    },
    
    // Move the action buttons so they immediately follow the filter.  
    // This works in conjunction with making the div.DTTT_container float left.
    moveButtons: function(containerID)
    {
        var buttons = $("#" + containerID).find(".DTTT_container");
        
        var filter = $("#" + containerID).find(".dataTables_filter");
        
        $(filter[0]).after(buttons);
    },

    createTable: function(tableID, columns, initialSort, clickHandler, tableActions, serverSideURL, afterServerDataCallback)
    {
        var tableConfig = this.getSelectableTableConfiguration(tableID, columns, initialSort, clickHandler, tableActions, serverSideURL, afterServerDataCallback);

        var table = $("#" + tableID + "Table").dataTable(tableConfig);
        
        // Use plugin to cause second delay when entering in search field
        table.fnSetFilteringDelay(1000);

        var containerID = tableID + "TableContainer";

        this.addClearFilterButton(containerID, table);
        
        this.moveButtons(containerID);

        $($("#" + tableID + "Table")[0].parentNode).scroll(Table.saveTableScrollPosition);

        $("#" + tableID + "Table").on("page", Table.saveTablePageNumber);

        return table;
    },

    getSelectableTableConfiguration: function(tableID, columns, initialSort, clickHandler, tableActions, serverSideURL, afterServerDataCallback)
    {
        var config = {
                         "aoColumns":       columns,
                         "sPaginationType": "full_numbers",
                         "aLengthMenu":     [[5, 10, 25, 50, 100, 250, 500, 1000], [5, 10, 25, 50, 100, 250, 500, 1000]],
                         "iDisplayLength":  10,
                         "sScrollY":        "300px",
                         "bScrollCollapse": true,
                         "sDom":            'T<"clear">lfrtip',
                         "bAutoWidth":      false,
                         "aaSorting":       initialSort,
                         "oTableTools":     {        
                                                "sSwfPath": "js/external/jquery/TableTools-2.1.5/media/swf/copy_csv_xls_pdf.swf",
                                                "aButtons": [ ]
                                            }
                     };
        
        if (serverSideURL)
        {
            config.iDeferLoading = 0;
            config.bServerSide   = true;
            config.bProcessing   = true;
            config.sAjaxDataProp = "items";
            config.sAjaxSource   = serverSideURL;
            config.sServerMethod = "GET";
            config.fnServerData  = function(sSource, aoData, fnCallback, oSettings) 
            {
                AdminUI.hideErrorPage();
                
                var deferred = $.ajax({ 
                                          dataType: "json",
                                          type:     "GET",
                                          url:      sSource,
                                          async:    false, // This needs to be sync or we cannot know when to reset selection after fnDraw.
                                          data:     aoData
                                      });
                
                deferred.done(function(result, status)
                {            
                    if (!result.items.connected)
                    {
                        var errorText = "This page requires data from services that are currently unavailable";
                        
                        // Support additional error information if provided from the server
                        if (result.items.error)
                        {
                            errorText +=". Error: " + result.items.error;
                        }
                        
                        AdminUI.showErrorPage(errorText);
                    }
                    
                    // Have to modify the items to get them to work since we want to return 
                    // connected and items initially as children of outermost items, but jquery
                    // just wants the leaf items array.
                    result.items = result.items.items;
                    fnCallback(result, status);
                    
                    // The Stats tab needs to know when new server data has been fetched so it can redraw its graph
                    if (afterServerDataCallback != null)
                    {
                        afterServerDataCallback();
                    }
                });
                
                deferred.fail(function(xhr, status, error)
                {
                    if (xhr.status == 303)
                    {
                        window.location.href = Constants.URL__LOGIN;
                    }
                    else
                    {
                        AdminUI.showErrorPage("This page requires data from services that are currently unavailable");
                        
                        // Have to make the callback or the table processing message won't terminate
                        fnCallback({iTotalRecords:0, iTotalDisplayRecords:0, items:[]}, status);
                        
                        // The Stats tab needs to know when new server data has been fetched so it can redraw its graph
                        if (afterServerDataCallback != null)
                        {
                            afterServerDataCallback();
                        }
                    }
                });
            };
        }

        if (clickHandler != null)
        {
            config.oTableTools.sRowSelect      = "single";
            config.oTableTools.fnRowSelected   = clickHandler;
            config.oTableTools.fnRowDeselected = clickHandler;
        }
        else
        {
            config.oTableTools.sRowSelect = "none"; 
        }

        if ((tableActions != null) && (AdminUI.settings.admin))
        {
            for (var actionIndex = 0; actionIndex < tableActions.length; actionIndex++)
            {
                var tableAction = tableActions[actionIndex];
                config.oTableTools.aButtons.push({
                                                     "sExtends":    "text",
                                                     "sButtonText": tableAction.text,
                                                     "fnClick":     tableAction.click
                                                 });
            }
        }

        config.oTableTools.aButtons.push({
                                             "sExtends": "copy",
                                             "fnClick":  function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                         });
        config.oTableTools.aButtons.push("print");
        config.oTableTools.aButtons.push({
                                             "sExtends":    "collection",
                                             "sButtonText": "Save",
                                             "aButtons":    
                                             [
                                                 {
                                                     "sExtends": "csv",
                                                     "fnClick":  function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                                 },
                                                 {
                                                     "sExtends": "xls",
                                                     "fnClick":  function(nButton, oConfig, flash) { Table.raw(nButton, oConfig, flash, tableID); }
                                                 },
                                                 {
                                                     "sExtends": "pdf",
                                                     "fnClick":  function(nButton, oConfig, flash) { Table.rawPDF(nButton, oConfig, flash, tableID); }
                                                 }
                                             ]
                                         });

        if (serverSideURL) 
        {
            config.oTableTools.aButtons.push({
                                                 "sExtends":    "text",
                                                 "sButtonText": "Download",
                                                 "fnClick":     function() { Table.download(columns, serverSideURL); }
            });
        }

        return config;
    },    

    raw: function(nButton, oConfig, flash, tableID)
    {
        var tableTools = TableTools.fnGetInstance(tableID + "Table");
        
        Format.raw = true;

        tableTools.fnSetText(flash, tableTools.fnGetTableData(oConfig));

        Format.raw = false;
    },

    rawPDF: function(nButton, oConfig, flash, tableID)
    {
        var tableTools = TableTools.fnGetInstance(tableID + "Table");
        
        Format.raw = true;

        tableTools.fnSetText(flash, tableTools.fnGetTableData(oConfig));

        tableTools.fnSetText(flash, "title:"                + tableTools.fnGetTitle(oConfig)      + "\n" +
                                    "message:"              + oConfig.sPdfMessage                 + "\n" +
                                    "colWidth:"             + tableTools.fnCalcColRatios(oConfig) + "\n" +
                                    "orientation:"          + oConfig.sPdfOrientation             + "\n" +
                                    "size:"                 + oConfig.sPdfSize                    + "\n" +
                                    "--/TableToolsOpts--\n" + tableTools.fnGetTableData(oConfig));

        Format.raw = false;
    },

    download: function(columns, serverSideURL)
    {
        AdminUI.showModalDialogProgress("Download");

        try
        {
            var headings = [];
            for (var columnIndex = 0; columnIndex < columns.length; columnIndex++)
            {
                var column = columns[columnIndex];
                headings.push(column.sTitle.replace(/&nbsp;/g," "));
            }
            
            var input   = document.createElement("input");
            input.type  = "text";
            input.name  = "headings";
            input.value = JSON.stringify(headings);
            
            var form     = document.createElement("form");
            form.method  = "POST";
            form.action  = serverSideURL;
            
            form.appendChild(input);
            
            $("body").append(form);
            
            try
            {
                form.submit();
            }
            finally
            {
                form.remove();
            }
        }
        finally
        {
            AdminUI.hideModalDialog();
        }
    },
    
    getTablePageNumber: function(table)
    {
        var settings = table.fnSettings();

        return settings._iDisplayLength === -1 ? 0 : Math.ceil(settings._iDisplayStart / settings._iDisplayLength);
    },

    isSelectedTableRowVisible: function(type)
    {
        var tableName = type + "Table";
        
        var tableTools = TableTools.fnGetInstance(tableName);
        
        var selected = tableTools.fnGetSelected();
        
        var visible = false;
        
        if (selected.length > 0)
        {
            var row = selected[0];

            var table = $("#" + tableName)[0];

            var scrollBody = table.parentNode;

            var scrollPosition = scrollBody.scrollTop;

            var tableHeight = scrollBody.clientHeight;
            
            var rowTop    = row.firstChild.offsetTop;
            var rowHeight = row.clientHeight;

            if ((rowTop > scrollPosition) && ((rowTop + rowHeight) < (scrollPosition + tableHeight)))
            {
                visible = true;
            }
        }

        return visible;
    },

    restoreSelectedTableRowVisible: function(type)
    {
        if (Table.tableSelectedRowVisible[type + "Table"])
        {
            Table.scrollSelectedTableRowIntoView(type);  
        }
    },

    restoreTablePageNumber: function(type)
    {
        var table = $("#" + type + "Table").dataTable();
        if (table != null)
        {
            var pageNumber = Table.tablePageNumbers[type + "Table"] || 0;

            // The fnPageChange triggers a saveTableScrollPosition() which corrupts the scroll position...
            Table.ignoreScroll = true;
            
            try
            {
                table.fnPageChange(pageNumber);
            }
            finally
            {
                Table.ignoreScroll = false;
            }
        }
    },

    restoreTableScrollPosition: function(type)
    {
        var table = $("#" + type + "Table")[0];
        if (table != null)
        {
            var scrollPosition = Table.tableScrollPositions[type + "Table"];

            table.parentNode.scrollTop = scrollPosition;
        }
    },

    saveSelectedTableRowVisible: function()
    {
        var type = $(".menuItemSelected").attr("id");
        if (type != null)
        {
            Table.tableSelectedRowVisible[type + "Table"] = Table.isSelectedTableRowVisible(type);
        }
    },

    saveTablePageNumber: function(event)
    {
        var tableName = event.currentTarget.id;

        var table = $("#" + tableName).dataTable();

        var pageNumber = Table.getTablePageNumber(table);

        Table.tablePageNumbers[tableName] = pageNumber;
    },

    saveTableScrollPosition: function(event)
    {
        if (!Table.ignoreScroll)
        {
            Table.tableScrollPositions[event.target.childNodes[0].id] = event.target.scrollTop;

            Table.saveSelectedTableRowVisible();
        }
    },   

    scrollSelectedTableRowIntoView: function(tableType)
    {
        var tableName = tableType + "Table";
        
        var tableTools = TableTools.fnGetInstance(tableName);
        
        var selected = tableTools.fnGetSelected();
        
        if (selected.length > 0)
        {
            var row = selected[0];
            
            var table = $("#" + tableName)[0];

            var scrollHeight = table.scrollHeight;

            var scrollBody = table.parentNode;

            var scrollPosition = scrollBody.scrollTop;

            var tableHeight = scrollBody.clientHeight;

            var rowTop    = row.firstChild.offsetTop;
            var rowHeight = row.clientHeight;

            var newTop = scrollPosition;

            /*
            if (rowTop < scrollPosition)
            {
                newTop = (rowTop - rowHeight);
    
            }
            else if ((rowTop + rowHeight) > (scrollPosition + tableHeight))
            {
                newTop = rowTop - tableHeight + (rowHeight * 2);
            }
            */
    
            if ((rowTop < scrollPosition) || ((rowTop + rowHeight) > (scrollPosition + tableHeight)))
            {
                newTop = rowTop - (tableHeight / 2) + (rowHeight / 2);
            }

            newTop = Math.max(newTop, 0);
            newTop = Math.min(newTop, (scrollHeight - tableHeight));
    
            if (newTop != scrollPosition)
            {
                scrollBody.scrollTop = newTop;
            }
        }
    },

    setTableScrollPosition: function(type, scrollPosition)
    {
        Table.tableScrollPositions[type + "Table"] = scrollPosition;

        var table = $("#" + type + "Table")[0];
        if (table != null)
        {
            table.parentNode.scrollTop = scrollPosition;
        }
    }
};
