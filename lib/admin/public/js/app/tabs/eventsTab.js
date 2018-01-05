
function EventsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__EVENTS, Constants.URL__EVENTS_VIEW_MODEL);
}

EventsTab.prototype = new Tab();

EventsTab.prototype.constructor = EventsTab;

EventsTab.prototype.getInitialSort = function()
{
    return [[0, "desc"]];
};

EventsTab.prototype.getColumns = function()
{
    return [
               {
                   title:  "Timestamp",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Type",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Type",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatEventName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Type",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Username",
                   width:  "200px",
                   render: Format.formatEventName
               },
               {
                   title:  "Name",
                   width:  "200px",
                   render: Format.formatEventName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

EventsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 1);
};

EventsTab.prototype.showDetails = function(table, objects, row)
{
    var event        = objects.event;
    var organization = objects.organization;
    var space        = objects.space;

    this.addJSONDetailsLinkRow(table, "Event Timestamp", Format.formatDateString(event.timestamp), objects, true);
    this.addPropertyRow(table, "Event GUID", Format.formatString(event.guid));
    this.addPropertyRow(table, "Event Type", Format.formatString(event.type));

    this.addPropertyRow(table, "Actee Type", Format.formatString(event.actee_type));
    this.addRowIfValue(this.addPropertyRow, table, "Actee", Format.formatString, event.actee_name);
    this.addCalculatedFilterRow(table, "Actee GUID", event.actee_type, event.actee_name, event.actee);

    this.addPropertyRow(table, "Actor Type", Format.formatString(event.actor_type));
    this.addRowIfValue(this.addPropertyRow, table, "Actor Username", Format.formatString, event.actor_username);
    this.addRowIfValue(this.addPropertyRow, table, "Actor", Format.formatString, event.actor_name);
    this.addCalculatedFilterRow(table, "Actor GUID", event.actor_type, event.actor_name, event.actor);

    if (space != null)
    {
        this.addFilterRow(table, "Space", Format.formatStringCleansed(space.name), space.guid, AdminUI.showSpaces);
        this.addPropertyRow(table, "Space GUID", Format.formatString(space.guid));
    }

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }
};

EventsTab.prototype.addCalculatedFilterRow = function(table, label, type, name, guid)
{
    var filterFunction = null;

    if (type == "app")
    {
        filterFunction = AdminUI.showApplications;
    }
    else if (type == "organization")
    {
        filterFunction = AdminUI.showOrganizations;
    }
    else if (type == "route")
    {
        filterFunction = AdminUI.showRoutes;
    }
    else if (type == "service")
    {
        filterFunction = AdminUI.showServices;
    }
    else if (type == "service_binding")
    {
        filterFunction = AdminUI.showServiceBindings;
    }
    else if (type == "service_broker")
    {
        filterFunction = AdminUI.showServiceBrokers;
    }
    else if (type == "service_dashboard_client")
    {
        filterFunction = AdminUI.showClients;
    }
    else if (type == "service_instance")
    {
        filterFunction = AdminUI.showServiceInstances;
    }
    else if (type == "service_key")
    {
        filterFunction = AdminUI.showServiceKeys;
    }
    else if (type == "service_plan")
    {
        filterFunction = AdminUI.showServicePlans;
    }
    else if (type == "service_plan_visibility")
    {
        filterFunction = AdminUI.showServicePlanVisibilities;
    }
    else if (type == "space")
    {
        filterFunction = AdminUI.showSpaces;
    }
    else if (type == "user")
    {
        if (name != null)
        {
            filterFunction = AdminUI.showUsers;
        }
        else
        {
            filterFunction = AdminUI.showClients;
        }
    }
    else if (type == "user_provided_service_instance")
    {
        filterFunction = AdminUI.showServiceInstances;
    }

    if (filterFunction != null)
    {
        this.addFilterRow(table, label, Format.formatString(guid), guid, filterFunction);
    }
    else
    {
        this.addPropertyRow(table, label, Format.formatString(guid));
    }
};
