function ServicePlansTab(id) 
{
    this.url = Constants.URL__SERVICE_PLANS;
    Tab.call(this, id);
}

ServicePlansTab.prototype             = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.getInitialSort = function() 
{
    return [[2, "asc"]];
};

ServicePlansTab.prototype.getColumns = function() 
{
    return [
                {
                    "sTitle": "&nbsp;",
                    "sWidth": "3px",
                    "sClass" : "cellCenterAlign",
                    "bSortable" : false,
                    "mRender" : function(value, type) 
                    {
                        return '<input type="checkbox" value="' + value + '" onclick="ServicePlansTab.prototype.checkboxClickHandler(event)"></input>';
                    }
                },
                {
                    "sTitle" : "Name",
                    "sWidth" : "200px",
                    "mRender" : Format.formatServiceString
                },
                {
                    "sTitle":  "Target",
                    "sWidth":  "200px",
                    "mRender": Format.formatTarget
                },
                {
                    "sTitle" : "Created",
                    "sWidth" : "170px",
                    "mRender" : Format.formatDateString
                },
                {
                    "sTitle" : "Updated",
                    "sWidth" : "170px",
                    "mRender" : Format.formatDateString
                },
                {
                    "sTitle" : "Public",
                    "sWidth" : "70px"
                },
                {
                    "sTitle" : "Service Instances",
                    "sWidth" : "80px",
                    "sClass":  "cellRightAlign",
                    "mRender" : Format.FormatNumber
                },
                {
                    "sTitle" : "Provider",
                    "sWidth" : "100px",
                    "mRender" : Format.formatServiceString
                },
                {
                    "sTitle":  "Label",
                    "sWidth":  "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle" : "Version",
                    "sWidth" : "100px",
                    "mRender" : Format.formatServiceString
                },
                {
                    "sTitle" : "Created",
                    "sWidth" : "170px",
                    "mRender" : Format.formatDateString
                },
                {
                    "sTitle" : "Updated",
                    "sWidth" : "170px",
                    "mRender" : Format.formatDateString
                },
                {
                    "sTitle" : "Active",
                    "sWidth" : "80px"
                },
                {
                    "sTitle" : "Bindable",
                    "sWidth" : "80px"
                },
                {
                    "sTitle" : "Name",
                    "sWidth" : "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle" : "Created",
                    "sWidth" : "170px",
                    "mRender" : Format.formatDateString
                },
                {
                    "sTitle" : "Updated",
                    "sWidth" : "170px",
                    "mRender" : Format.formatDateString
                }
            ];
};

ServicePlansTab.prototype.getActions = function() 
{
    return [
               {
                   text : " Public ",
                   click : $.proxy(function() 
                   {
                       this.changeVisibility("public");
                   }, 
                   this)
               },
               {
                   text : "Private",
                   click : $.proxy(function() 
                   {
                       this.changeVisibility("private");
                   }, 
                   this)
               }
           ];
};

ServicePlansTab.prototype.linkClickHandler = function(service_plan_name) 
{
    AdminUI.showServiceInstances(service_plan_name);
};

ServicePlansTab.prototype.refresh = function(reload) 
{
    var servicePlansDeferred     = Data.get(Constants.URL__SERVICE_PLANS, reload);
    var servicesDeferred         = Data.get(Constants.URL__SERVICES, reload);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, reload);
    var serviceBrokersDeferred   = Data.get(Constants.URL__SERVICE_BROKERS, reload);
    
    $.when(servicePlansDeferred, servicesDeferred, serviceInstancesDeferred, serviceBrokersDeferred).done(
        $.proxy(function(servicePlansResult, servicesResult, serviceInstancesResult, serviceBrokersResult) 
        {
            this.updateData([servicePlansResult, servicesResult, serviceInstancesResult, serviceBrokersResult], reload);
            this.table.fnDraw();
        }, this));
};

ServicePlansTab.prototype.getTableData = function(results) 
{
    var servicePlans     = results[0].response.items;
    var services         = results[1].response.items;
    var serviceInstances = results[2].response.items;
    var serviceBrokers   = results[3].response.items;

    var serviceBrokerMap = [];

    for (var serviceBrokerIndex in serviceBrokers)
    {
        var serviceBroker                    = serviceBrokers[serviceBrokerIndex];
        serviceBrokerMap[serviceBroker.guid] = serviceBroker;
    }

    var serviceMap = [];

    for (var serviceIndex in services)
    {
        var service              = services[serviceIndex];
        serviceMap[service.guid] = service;
    }

    var servicePlanMap = [];

    for (var servicePlanIndex in servicePlans)
    {
        var servicePlan                     = servicePlans[servicePlanIndex];
        servicePlan.service_instances_count = 0;  //initialize service instances count per service plan to zero
        servicePlanMap[servicePlan.guid]    = servicePlan;
    }
    
    //count the service instances per service plan
    for (var serviceInstanceIndex in serviceInstances)
    {
        var serviceInstance = serviceInstances[serviceInstanceIndex];
        var servicePlan     = servicePlanMap[serviceInstance.service_plan_guid];

        if (servicePlan != null)
        {
            servicePlan.service_instances_count += 1;  
        }
    }
    
    //populate table with data
    
    var tableData = [];
    for (var servicePlanIndex in servicePlans)
    {
        var servicePlan   = servicePlans[servicePlanIndex];
        var service       = (servicePlan == null) ? null : serviceMap[servicePlan.service_guid];
        var serviceBroker = (service == null || service.service_broker_guid == null) ? null : serviceBrokerMap[service.service_broker_guid];
        var row           = [];
        var addon         = {};

        row.push(servicePlan.guid);
        row.push(servicePlan.name);
        
        var servicePlanTarget = "";
        if (service != null)
        {
            if (service.provider != null)
            {
                servicePlanTarget = service.provider;
            }
            servicePlanTarget += "/" + service.label + "/";
        }
        servicePlanTarget += servicePlan.name;
        row.push(servicePlanTarget);

        row.push(servicePlan.created_at);
        
        if (servicePlan.updated_at != null)
        {
            row.push(servicePlan.updated_at);
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 1);
        }
        
        row.push(servicePlan.public);
        row.push(servicePlan.service_instances_count);
        addon.servicePlan = servicePlan;

        if (service != null)
        {
            row.push(service.provider);
            row.push(service.label);
            row.push(service.version);
            row.push(service.created_at);
            
            if (service.updated_at != null)
            {
                row.push(service.updated_at);
            }
            else
            {
                Utilities.addEmptyElementsToArray(row, 1);
            }

            row.push(service.active);
            row.push(service.bindable);
            addon.service = service;
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 7);
        }

        if (serviceBroker != null)
        {
            row.push(serviceBroker.name);
            row.push(serviceBroker.created_at);
            
            if (serviceBroker.updated_at != null)
            {
                row.push(serviceBroker.updated_at);
            }
            else
            {
                Utilities.addEmptyElementsToArray(row, 1);
            }

            addon.serviceBroker = serviceBroker;
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 3);
        }

        row.push(addon);
        tableData.push(row);
    }

    return tableData;
};

ServicePlansTab.prototype.clickHandler = function(event) 
{
    var tableTools = TableTools.fnGetInstance("ServicePlansTable");
    var selected   = tableTools.fnGetSelectedData();

    this.hideDetails();
    
    if (selected.length > 0)
    {
        $("#ServicePlansDetailsLabel").show();

        var containerDiv  = $("#ServicePlansPropertiesContainer").get(0);
        var table         = this.createPropertyTable(containerDiv);
        var row           = selected[0];
        var target        = row[17];
        var serviceBroker = target.serviceBroker;
        var service       = target.service;
        var servicePlan   = target.servicePlan;

        if (servicePlan != null)
        {
            //create a link
            var serviceInstancesLink = document.createElement("a");
            $(serviceInstancesLink).attr("href", "");
            $(serviceInstancesLink).addClass("tableLink");
            $(serviceInstancesLink).html(Format.formatNumber(servicePlan.service_instances_count));
            $(serviceInstancesLink).click(function()
            {
                AdminUI.showServiceInstances(row[2]);

                return false;
            });

            this.addJSONDetailsLinkRow(table, "Service Plan Name", Format.formatString(servicePlan.name), target, true);
            this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
            this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
            this.addPropertyRow(table, "Service Plan Public", Format.formatBoolean(servicePlan.public));
            this.addPropertyRow(table, "Service Plan Description", Format.formatString(servicePlan.description));
            this.addRow(table, "Service Instances", serviceInstancesLink);
        }
        
        if (serviceBroker != null)
        {
            this.addPropertyRow(table, "Service Broker Name", Format.formatString(serviceBroker.name));
            this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
            this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
        }

        if (service != null)
        {
            this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
            this.addPropertyRow(table, "Service Label", Format.formatString(service.label));
            this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
            this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
            this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
            this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
            this.addPropertyRow(table, "Service Bindable", Format.formatString(service.bindable));
            this.addPropertyRow(table, "Service Description", Format.formatString(service.description));
            
            if (service.extra != null)
            {
                var serviceExtra = jQuery.parseJSON(service.extra);
                this.addRowIfValue(this.addPropertyRow, table, "Service Display Name", Format.formatString, serviceExtra.displayName);
                this.addRowIfValue(this.addPropertyRow, table, "Service Provider Display Name", Format.formatString, serviceExtra.providerDisplayName);
                this.addRowIfValue(this.addFormattableTextRow, table, "Service Icon", Format.formatIconImage, serviceExtra.imageUrl, "service icon", "flot:left;");
                this.addRowIfValue(this.addPropertyRow, table, "Service Long Description", Format.formatString, serviceExtra.longDescription);
            }
        }
    }
};

ServicePlansTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

ServicePlansTab.prototype.changeVisibility = function(targetedVisibility) 
{
    if (!targetedVisibility || 
        (targetedVisibility != Constants.STATUS__PUBLIC && 
         targetedVisibility != Constants.STATUS__PRIVATE ) ) 
    {
        return;
    }

    var rows = this.getSelectedRowsOfMainTable();

    if (!rows || rows.length == 0) 
    {
        return;  //quit when there is nothing picked.
    }

    AdminUI.showModalDialog({ "body": $('<label>"Performing operation, please wait..."</label>') });
    var error_servicePlans = [];
    var isPlanChanged      = false;
    for (var rowIdx = 0, rowCount = rows.length; rowIdx < rowCount; rowIdx++) 
    {
        var row = rows[rowIdx];

        var url = "/service_plans/" + row[0]; ;
        var body = (targetedVisibility === Constants.STATUS__PUBLIC) ? '{"public": true}': '{"public": false }';
        
        $.ajax(
        {
            type: 'PUT',
            async : false,
            url : url,
            contentType : "application/json; charset=utf-8",
            dataType : "json",
            data: body,
            success : function(data) 
            {
                var servicePlanName = row[1];
                console.log(Utilities.localize("Service plan {0} is changed to {1}.", [ servicePlanName, targetedVisibility ]));
                isPlanChanged = true;
                AdminUI.refresh();
            },
            error : function(msg) 
            {
                var servicePlanName = row[1];
                error_servicePlans.push(servicePlanName);
            }
        });
    }

    AdminUI.closeModalDialog();

    if (isPlanChanged)
    {
        alert("The operation finished without error.\nPlease refresh the page later for the updated result.");
    }
    if (error_servicePlans.length > 0) 
    {
        alert("Error handling the following service plans:\n" + error_servicePlans);
    } 
};

ServicePlansTab.prototype.getSelectedRowsOfMainTable = function() 
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        alert("Please select at least one row!");
        return null;
    }

    var selectedRows = [];

    var servicePlansDeferred = Data.get(Constants.URL__SERVICE_PLANS, false);
    var servicesDeferred = Data.get(Constants.URL__SERVICES, false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);
    var serviceBrokersDeferred = Data.get(Constants.URL__SERVICE_BROKERS, false);

    $.when(servicePlansDeferred, servicesDeferred, serviceInstancesDeferred, serviceBrokersDeferred).done(
        $.proxy(function(servicePlansResult, servicesResult, serviceInstancesResult, serviceBrokersResult) 
        {
            var tableData = this.getTableData([servicePlansResult, servicesResult, serviceInstancesResult, serviceBrokersResult]);
            for (var rowIdx = 0, rowCount = tableData.length; rowIdx < rowCount; rowIdx++) 
            {
                var row = tableData[rowIdx];
                for (var checkRowIdx = 0; checkRowIdx < checkedRows.length; checkRowIdx++) 
                {
                    var selectedValue = checkedRows[checkRowIdx].value;
                    if (selectedValue && selectedValue === row[0] ) 
                    { 
                        selectedRows.push(row);
                    }
                }
            } 
        }, this));
    return selectedRows;
};

// We have to search by GUID since service plan names are not unique.
ServicePlansTab.prototype.showServicePlan = function(servicePlanGUID) 
{
    // Several calls in this function trigger a saveTableScrollPosition() which corrupts the scroll position.
    Table.ignoreScroll = true;
    
    // Save and clear the sorting so we can select by index.
    var sorting = this.table.fnSettings().aaSorting;
    this.table.fnSort([]);

    var servicePlansDeferred     = Data.get(Constants.URL__SERVICE_PLANS, false);
    var servicesDeferred         = Data.get(Constants.URL__SERVICES, false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);
    var serviceBrokersDeferred   = Data.get(Constants.URL__SERVICE_BROKERS, false);

    $.when(servicePlansDeferred, servicesDeferred, serviceInstancesDeferred, serviceBrokersDeferred).done(
        $.proxy(function(servicePlansResult, servicesResult, serviceInstancesResult, serviceBrokersResult) 
    {
        var tableData = this.getTableData([servicePlansResult, servicesResult, serviceInstancesResult, serviceBrokersResult]);
        this.table.fnClearTable();
        this.table.fnAddData(tableData);
        
        for (var index = 0; index < tableData.length; index++)
        {
            var row = tableData[index];
            
            var target      = row[17];
            var servicePlan = target.servicePlan;

            if (servicePlan.guid == servicePlanGUID)
            {           
                // Select the service plan.
                Table.selectTableRow(this.table, index);

                // Restore the sorting.
                this.table.fnSort(sorting);

                // Move to the ServicePlans tab.
                AdminUI.setTabSelected(this.id);

                // Show the ServicePlans tab contents.
                this.show();

                Table.ignoreScroll = false;

                Table.scrollSelectedTableRowIntoView(this.id);                  

                break;
            }
        }
    }, 
    this));
};
