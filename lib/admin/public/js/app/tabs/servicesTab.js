function ServicesTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICES_VIEW_MODEL);
}

ServicesTab.prototype = new Tab();

ServicesTab.prototype.constructor = ServicesTab;

ServicesTab.prototype.getInitialSort = function() 
{
    return [[1, "asc"]];
};

ServicesTab.prototype.getColumns = function() 
{
    return [
                {
                    "sTitle": "Provider",
                    "sWidth": "100px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle":  "Label",
                    "sWidth":  "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle": "GUID",
                    "sWidth": "200px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Version",
                    "sWidth": "100px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle": "Created",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Active",
                    "sWidth": "80px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Bindable",
                    "sWidth":  "80px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Service Plans",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Instances",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Name",
                    "sWidth":  "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle":  "GUID",
                    "sWidth":  "200px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Created",
                    "sWidth":  "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                }
            ];
};

ServicesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicesTab.prototype.showDetails = function(table, objects, row)
{
    var service       = objects.service;
    var serviceBroker = objects.serviceBroker;

    this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
    this.addJSONDetailsLinkRow(table, "Service Label", Format.formatString(service.label), objects, true);
    this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
    this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
    this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
    this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
    this.addPropertyRow(table, "Service Bindable", Format.formatString(service.bindable));
    this.addPropertyRow(table, "Service Description", Format.formatString(service.description));
    
    if (service.tags != null)
    {
        var serviceTags = jQuery.parseJSON(service.tags);
        
        if (serviceTags != null && serviceTags.length > 0)
        {
            for (var serviceTagIndex = 0; serviceTagIndex < serviceTags.length; serviceTagIndex++)
            {
                var serviceTag = serviceTags[serviceTagIndex];

                this.addPropertyRow(table, "Service Tag", Format.formatString(serviceTag));
            }
        }
    }
    
    // Documentation URL for v1 service
    if (service.documentation_url != null)
    {
        var documentationLink = document.createElement("a");
        $(documentationLink).attr("target", "_blank");
        $(documentationLink).attr("href", service.documentation_url);
        $(documentationLink).addClass("tableLink");
        $(documentationLink).html(service.documentation_url);

        this.addRow(table, "Service Documentation URL", documentationLink);
    }

    // Info URL for v1 service
    if (service.info_url != null)
    {
        var infoLink = document.createElement("a");
        $(infoLink).attr("target", "_blank");
        $(infoLink).attr("href", service.info_url);
        $(infoLink).addClass("tableLink");
        $(infoLink).html(service.info_url);

        this.addRow(table, "Service Info URL", infoLink);
    }

    if (service.extra != null)
    {
        var serviceExtra = jQuery.parseJSON(service.extra);
        this.addRowIfValue(this.addPropertyRow, table, "Service Display Name", Format.formatString, serviceExtra.displayName);
        this.addRowIfValue(this.addPropertyRow, table, "Service Provider Display Name", Format.formatString, serviceExtra.providerDisplayName);
        this.addRowIfValue(this.addFormattableTextRow, table, "Service Icon", Format.formatIconImage, serviceExtra.imageUrl, "service icon", "flot:left;");
        this.addRowIfValue(this.addPropertyRow, table, "Service Long Description", Format.formatString, serviceExtra.longDescription);
        
        if (serviceExtra.documentationUrl != null)
        {
            var documentationLink = document.createElement("a");
            $(documentationLink).attr("target", "_blank");
            $(documentationLink).attr("href", serviceExtra.documentationUrl);
            $(documentationLink).addClass("tableLink");
            $(documentationLink).html(serviceExtra.documentationUrl);

            this.addRow(table, "Service Documentation URL", documentationLink);
        }
        
        if (serviceExtra.supportUrl != null)
        {
            var supportLink = document.createElement("a");
            $(supportLink).attr("target", "_blank");
            $(supportLink).attr("href", serviceExtra.supportUrl);
            $(supportLink).addClass("tableLink");
            $(supportLink).html(serviceExtra.supportUrl);

            this.addRow(table, "Service Support URL", supportLink);
        }
    }
    
    var target = service.provider + "/" + service.label + "/";

    var servicePlansLink = document.createElement("a");
    $(servicePlansLink).attr("href", "");
    $(servicePlansLink).addClass("tableLink");
    $(servicePlansLink).html(Format.formatNumber(row[8]));
    $(servicePlansLink).click(function()
    {
        AdminUI.showServicePlans(target);

        return false;
    });
    this.addRow(table, "Service Plans", servicePlansLink);

    var serviceInstancesLink = document.createElement("a");
    $(serviceInstancesLink).attr("href", "");
    $(serviceInstancesLink).addClass("tableLink");
    $(serviceInstancesLink).html(Format.formatNumber(row[9]));
    $(serviceInstancesLink).click(function()
    {
        AdminUI.showServiceInstances(target);

        return false;
    });
    this.addRow(table, "Service Instances", serviceInstancesLink);
    
    if (serviceBroker != null)
    {
        var serviceBrokerLink = document.createElement("a");
        $(serviceBrokerLink).attr("href", "");
        $(serviceBrokerLink).addClass("tableLink");
        $(serviceBrokerLink).html(Format.formatString(serviceBroker.name));
        $(serviceBrokerLink).click(function()
        {
            AdminUI.showServiceBrokers(serviceBroker.guid);

            return false;
        });
        this.addRow(table, "Service Broker Name", serviceBrokerLink);
        
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }
};
