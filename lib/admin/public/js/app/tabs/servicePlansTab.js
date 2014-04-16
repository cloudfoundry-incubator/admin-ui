function ServicePlansTab(id) 
{
    this.url = Constants.URL__SERVICE_PLANS;
    Tab.call(this, id);
}

ServicePlansTab.prototype             = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.initialize = function() 
{
    this.table = Table.createTable(
        this.id,
        this.getColumns(),
        this.getInitialSort(),
        $.proxy(this.clickHandler, this),
        [
            {
                text : " Public ",
                click : $.proxy(function() 
                {
                    this.changeVisibility("public")
                }, this)
            },
            {
                text : "Private",
                click : $.proxy(function() 
                {
                    this.changeVisibility("private")
                }, this)
            }
        ]);
}

ServicePlansTab.prototype.getInitialSort = function() 
{
    return [[0, "asc"]];
}

ServicePlansTab.prototype.getColumns = function() 
{
    return [
                {
                    "sTitle" : "",
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
                    "sTitle" : "Created",
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
                    "sTitle" : "Active",
                    "sWidth" : "80px"
                },
                {
                    "sTitle" : "Bindable",
                    "sWidth" : "80px"
                },
                {
                    "sTitle" : "Description",
                    "sWidth" : "200px"
                }
            ];
}

ServicePlansTab.prototype.linkClickHandler = function(service_plan_name) 
{
    AdminUI.showServiceInstances(service_plan_name);
}

ServicePlansTab.prototype.refresh = function(reload) 
{
    var servicePlansDeferred     = Data.get(Constants.URL__SERVICE_PLANS, reload);
    var servicesDeferred         = Data.get(Constants.URL__SERVICES, reload);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, reload);
    
    $.when(servicePlansDeferred, servicesDeferred, serviceInstancesDeferred).done(
        $.proxy(function(servicePlansResult, servicesResult, serviceInstancesResult) 
        {
            this.updateData([servicePlansResult, servicesResult, serviceInstancesResult], reload);
            this.table.fnDraw();
        }, this));
}

ServicePlansTab.prototype.getTableData = function(results) 
{
    var servicePlans     = results[0].response.items;
    var services         = results[1].response.items;
    var serviceInstances = results[2].response.items;

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
    
    //count the service service instance per service_plan
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
        var servicePlan = servicePlans[servicePlanIndex];
        var service     = (servicePlan == null) ? null : serviceMap[servicePlan.service_guid];
        var row         = [];
        var addon       = {};

        if (servicePlan != null)
        {
            row.push(servicePlan.guid);
            row.push(servicePlan.name);
            row.push(servicePlan.created_at);
            row.push(servicePlan.public);
            row.push(servicePlan.service_instances_count);
            addon.service_plan = servicePlan;
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 5);
        }

        if (service != null)
        {
            row.push(service.provider);
            row.push(service.label);
            row.push(service.version);
            row.push(service.created_at);
            row.push(service.active);
            row.push(service.bindable);
            row.push(service.description);
            addon.service = service;
        }
        else
        {
            Utilities.addEmptyElementsToArray(row, 7);
        }

        row.push(addon);
        tableData.push(row);
    }

    return tableData;
}

ServicePlansTab.prototype.clickHandler = function(event) 
{
    var tableTools = TableTools.fnGetInstance("ServicePlansTable");
    var selected   = tableTools.fnGetSelectedData();

    this.hideDetails();
    hitchWhenHavingValue = function(scope, rowFunc, lable, formatter)
    {
        if (arguments.length <= 4 ||  arguments[4] == null || arguments[4] == "")
        {
        	return;
        }
        format = formatter(arguments[4], arguments[5], arguments[6]);
        return rowFunc.apply(scope, [table,  lable, format]);
    }

    if (selected.length > 0)
    {
        $("#ServicePlansDetailsLabel").show();

        var containerDiv = $("#ServicePlansPropertiesContainer").get(0);
        var table        = this.createPropertyTable(containerDiv);
        var row          = selected[0];
        var target       = row[12];
        var service      = target.service;
        var servicePlan  = target.service_plan;

        if (servicePlan != null)
        {
            //create a link
            var serviceInstancesink = document.createElement("a");
            $(serviceInstancesink).attr("href", "");
            $(serviceInstancesink).addClass("tableLink");
            $(serviceInstancesink).html(Format.formatNumber(servicePlan.service_instances_count));
            $(serviceInstancesink).click(function()
            {
                AdminUI.showServiceInstances(row[1]);

                return false;
            });

            this.addJSONDetailsLinkRow(table,                         "Service Plan Name",             Format.formatString(servicePlan.name), servicePlan, true);
            this.addPropertyRow(       table,                         "Service Plan Created",          Format.formatDate(servicePlan.created_at));
            this.addPropertyRow(       table,                         "Service Plan Public",           Format.formatBoolean(servicePlan.public));
            this.addRow(               table,                         "Service Instances",             serviceInstancesink);
        }

        if (service != null)
        {
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Provider",             Format.formatString,   service.provider );
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Label",                Format.formatString,   service.label);
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Version",              Format.formatString,   service.version);
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Created",              Format.formatDate,     service.created_at);
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Active",               Format.formatBoolean,  service.active);
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Bindable",             Format.formatString,   service.bindable);
            hitchWhenHavingValue(    this, this.addPropertyRow,        "Service Description",          Format.formatString,   service.description);
            
            if (service.extra != null)
            {
                var serviceExtra = jQuery.parseJSON(service.extra);
                hitchWhenHavingValue(this, this.addPropertyRow,        "Service Display Name",         Format.formatString,    serviceExtra.displayName);
                hitchWhenHavingValue(this, this.addPropertyRow,        "Service Provider Display Name",Format.formatString,    serviceExtra.providerDisplayName);
                hitchWhenHavingValue(this, this.addFormattableTextRow, "Service Icon",                 Format.formatIconImage, serviceExtra.imageUrl, "service icon", "flot:left;");
                hitchWhenHavingValue(this, this.addPropertyRow,        "Service Long Description",     Format.formatString,    serviceExtra.longDescription);
            }
        }
    }
}

ServicePlansTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
}

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

    AdminUI.showModalDialog("Performing operation, please wait...");
    var error_servicePlans = [];
    var isPlanChanged      = false;
    for (var rowIdx = 0, rowCount = rows.length; rowIdx < rowCount; rowIdx++) 
    {
        var row = rows[rowIdx];
        var isPlanPublic = row[3];

        var url = "/service_plans/" + row[0]; ;
        var servicePlanGUID = row[0];
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
        alert("Error handling the following applications:\n" + error_apps);
    } 
}

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

    $.when(servicePlansDeferred, servicesDeferred, serviceInstancesDeferred).done(
        $.proxy(function(servicePlansResult, servicesResult, serviceInstancesResult) 
        {
            var tableData = this.getTableData([servicePlansResult, servicesResult, serviceInstancesResult]);
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
}

ServicePlansTab.prototype.showServicePlan = function(filter) 
{

    AdminUI.setTabSelected(this.id);
    // Several calls in this function trigger a saveTableScrollPosition() which corrupts the scroll position.
    Table.ignoreScroll = true;

    // Save and clear the sorting so we can select by index.
    var sorting = this.table.fnSettings().aaSorting;
    this.table.fnSort([]);

    var servicePlansDeferred     = Data.get(Constants.URL__SERVICE_PLANS, false);
    var servicesDeferred         = Data.get(Constants.URL__SERVICES, false);
    var serviceInstancesDeferred = Data.get(Constants.URL__SERVICE_INSTANCES, false);

    $.when(servicePlansDeferred, servicesDeferred, serviceInstancesDeferred).done(
        $.proxy(function(servicePlansResult, servicesResult, serviceInstancesResult) 
        {
            var tableData = this.getTableData([servicePlansResult, servicesResult, serviceInstancesResult]);
            this.table.fnClearTable();
            this.table.fnAddData(tableData);
            this.table.fnFilter(filter);
            this.show();

        }, 
        this));

} 
