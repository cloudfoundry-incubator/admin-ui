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
                    this.changeVisibilit("public")
                }, this)
            },
            {
                text : "Private",
                click : $.proxy(function() 
                {
                    this.changeVisibilit("private")
                }, this)
            }
        ]);
}

ServicePlansTab.prototype.getInitialSort = function() 
{
    return [[0, "asc"]];
}

//Create enumeration only when it is necessary.
ServicePlansTab.ENUM_SERVICE_PLANE_CHECKBOX = 0;
ServicePlansTab.ENUM_SERVICE_PLANE_NAME     = 1;
ServicePlansTab.ENUM_SERVICE_PLANE_PUBLIC   = 3;
ServicePlansTab.ENUM_ADDON                  = 12;

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

    if (selected.length > 0)
    {
        $("#ServicePlansDetailsLabel").show();

        var containerDiv = $("#ServicePlansPropertiesContainer").get(0);
        var table        = this.createPropertyTable(containerDiv);
        var row          = selected[0];
        var target       = row[ServicePlansTab.ENUM_ADDON];
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
                AdminUI.showServiceInstances(row[4]);

                return false;
            });

            this.addPropertyRow(table, "Service Plan Name",                Format.formatString(servicePlan.name));
            this.addPropertyRow(table, "Service Plan Created",             Format.formatDate(servicePlan.created_at));
            this.addPropertyRow(table, "Service Plan Public",              Format.formatBoolean(servicePlan.public));
            this.addRow(        table, "Service Instances",                serviceInstancesink);
            this.addPropertyRow(table, "Service Plan GUID",                Format.formatString(servicePlan.guid));
        }

        if (service != null)
        {
            this.addPropertyRow(table, "Service Provider",                 Format.formatString(service.provider));
            this.addPropertyRow(table, "Service Label",                    Format.formatString(service.label));
            this.addPropertyRow(table, "Service Version",                  Format.formatString(service.version));
            this.addPropertyRow(table, "Service Created",                  Format.formatDate(service.created_at));
            this.addPropertyRow(table, "Service Active",                   Format.formatBoolean(service.active));
            this.addPropertyRow(table, "Service Bindable",                 Format.formatString(service.bindable));
            this.addPropertyRow(table, "Service Description",              Format.formatString(service.description));
            
            if (service.extra != null)
            {
                var serviceExtra = jQuery.parseJSON(service.extra);
                this.addPropertyRow(table, "Service Display Name",         Format.formatString(serviceExtra.displayName));
                this.addPropertyRow(table, "Service Provider Display Name",Format.formatString(serviceExtra.providerDisplayName));
                this.addFormattableTextRow(table, "Service Icon",          Format.formatIconImage(serviceExtra.imageUrl, "service icon", "flot:left;"));
                this.addPropertyRow(table, "Service Long Description",     Format.formatString(serviceExtra.longDescription));
            }
        }
    }
}

ServicePlansTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
}

ServicePlansTab.prototype.changeVisibilit = function(targetdVisibility) 
{

    if (!targetdVisibility || 
        (targetdVisibility != Constants.STATUS__PUBLIC && 
         targetdVisibility != Constants.STATUS__PRIVATE ) ) 
    {
        return;
    }

    var rows = this.getSelectedRowsOfMainTable();

    if (!rows || rows.length == 0) 
    {
        return;  //quit when there is nothing picked.
    }

    var message = Utilities.localize("You are about to make selected service plans {0}.  Do you want to continue?", [ targetdVisibility ]);

    if (!confirm(message) ) 
    {
        return;  //cancel
    }
    AdminUI.showModalDialog("<div  style=z-index:10;background-color:#FFFFFF;padding-top:12px;height:80px;line-height:24px;'><center><img class='icon-image' src='../../../../images/loading.gif' alt='Updating...' /><center><span>Update is in progress...</span></div>");

    var error_servicePlans = [];
    var isPlanChanged      = false;
    for (var rowIdx = 0, rowCount = rows.length; rowIdx < rowCount; rowIdx++) 
    {
        var row = rows[rowIdx];
        var isPlanPublic = row[ServicePlansTab.ENUM_SERVICE_PLANE_PUBLIC];
        if (isPlanPublic == (targetdVisibility === Constants.STATUS__PUBLIC) ) 
        {
            continue;
        }
        var url = "/service_plans/" + row[ServicePlansTab.ENUM_SERVICE_PLANE_CHECKBOX]; ;
        var servicePlanGUID = row[ServicePlansTab.ENUM_SERVICE_PLANE_CHECKBOX];
        var body = (targetdVisibility === Constants.STATUS__PUBLIC) ? '{"public": true}': '{"public": false }';
        
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
                var servicePlanName = row[ServicePlansTab.ENUM_SERVICE_PLANE_NAME];
                console.log(Utilities.localize("Service plan {0} is changed to {1}.", [ servicePlanName, targetdVisibility ]));
                isPlanChanged = true;
                AdminUI.refresh();
            },
            error : function(msg) 
            {
                var servicePlanName = row[ServicePlansTab.ENUM_SERVICE_PLANE_NAME];
                error_servicePlans.push(servicePlanName);
            }
        });
    }

    AdminUI.closeModalDialog();

    if (isPlanChanged)
    {
        alert("Update on service plans was completed successfully.");
    }
    if (error_servicePlans.length > 0) 
    {
        alert( Utilities.localizeSequence("Update on the following service plans encountered problems: {n}.", ", ", error_servicePlans));
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
                    if (selectedValue && selectedValue === row[ServicePlansTab.ENUM_SERVICE_PLANE_CHECKBOX] ) 
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
