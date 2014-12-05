function ServiceBrokersTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICE_BROKERS_VIEW_MODEL);
}

ServiceBrokersTab.prototype = new Tab();

ServiceBrokersTab.prototype.constructor = ServiceBrokersTab;

ServiceBrokersTab.prototype.getInitialSort = function() 
{
    return [[0, "asc"]];
};

ServiceBrokersTab.prototype.getColumns = function() 
{
    return [
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
                },
                {
                    "sTitle":  "Services",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
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

            ];
};

ServiceBrokersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

ServiceBrokersTab.prototype.showDetails = function(table, serviceBroker, row)
{
    this.addJSONDetailsLinkRow(table, "Service Broker Name", Format.formatString(serviceBroker.name), serviceBroker, true);
    this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
    this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);

    var servicesLink = document.createElement("a");
    $(servicesLink).attr("href", "");
    $(servicesLink).addClass("tableLink");
    $(servicesLink).html(Format.formatNumber(row[4]));
    $(servicesLink).click(function()
    {
        AdminUI.showServices(serviceBroker.guid);

        return false;
    });
    this.addRow(table, "Services", servicesLink);

    var servicePlansLink = document.createElement("a");
    $(servicePlansLink).attr("href", "");
    $(servicePlansLink).addClass("tableLink");
    $(servicePlansLink).html(Format.formatNumber(row[5]));
    $(servicePlansLink).click(function()
    {
        AdminUI.showServicePlans(serviceBroker.guid);

        return false;
    });
    this.addRow(table, "Service Plans", servicePlansLink);

    var serviceInstancesLink = document.createElement("a");
    $(serviceInstancesLink).attr("href", "");
    $(serviceInstancesLink).addClass("tableLink");
    $(serviceInstancesLink).html(Format.formatNumber(row[6]));
    $(serviceInstancesLink).click(function()
    {
        AdminUI.showServiceInstances(serviceBroker.guid);

        return false;
    });
    this.addRow(table, "Service Instances", serviceInstancesLink);
};
