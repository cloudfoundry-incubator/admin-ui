
function RoutesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ROUTES, Constants.URL__ROUTES_VIEW_MODEL);
}

RoutesTab.prototype = new Tab();

RoutesTab.prototype.constructor = RoutesTab;

RoutesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.routesLabelsTable = Table.createTable("RoutesLabels", this.getRoutesLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getRoutesLabelsActions(), Constants.FILENAME__ROUTE_LABELS, null, null);

    this.routesAnnotationsTable = Table.createTable("RoutesAnnotations", this.getRoutesAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getRoutesAnnotationsActions(), Constants.FILENAME__ROUTE_ANNOTATIONS, null, null);

    this.routesSharesTable = Table.createTable("RoutesShares", this.getRoutesSharesColumns(), [[1, "asc"]], null, this.getRoutesSharesActions(), Constants.FILENAME__ROUTE_SHARES, null, null);
};

RoutesTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

RoutesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var name = item[1];
                                          if (item[4] != null)
                                          {
                                              if (name.length > 0)
                                              {
                                                  name += ".";
                                              }

                                              name += item[4];
                                          }

                                          if (item[2] != null)
                                          {
                                              name += item[2];
                                          }

                                          return this.formatCheckbox(this.id, name, value);
                                      },
                                      this)
               },
               {
                   title:  "URI",
                   width:  "200px",
                   render: Format.formatURI
               },
               {
                   title:  "Host",
                   width:  "200px",
                   render: Format.formatRouteString
               },
               {
                   title:  "Domain",
                   width:  "200px",
                   render: Format.formatDomainName
               },
               {
                   title:     "Port",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Path",
                   width:  "200px",
                   render: Format.formatRouteString
               },
               {
                   title:     "VIP Offset",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Route Mappings",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Route Bindings",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                title:     "Route Shares",
                width:     "70px",
                className: "cellRightAlign",
                render:    Format.formatNumber
               },
               {
                   title:  "Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};

RoutesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected routes?",
                                                         "Delete",
                                                         "Deleting Routes",
                                                         Constants.URL__ROUTES,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Delete Recursive",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected routes and their associated route mappings and route bindings?",
                                                         "Delete Recursive",
                                                         "Deleting Routes and Associated Route Bindings",
                                                         Constants.URL__ROUTES,
                                                         "?recursive=true");
                                  },
                                  this)
               }
           ];
};

RoutesTab.prototype.getRoutesLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("RoutesLabels"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("RoutesLabels", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

RoutesTab.prototype.getRoutesLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("RoutesLabels",
                                                         "Are you sure you want to delete the route's selected labels?",
                                                         "Delete",
                                                         "Deleting Route Label",
                                                         Constants.URL__ROUTES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

RoutesTab.prototype.getRoutesAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("RoutesAnnotations"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          var text = item[2];
                                          if (item[1] != null)
                                          {
                                              text = item[1] + "/" + item[2];
                                          }

                                          return this.formatCheckbox("RoutesAnnotations", text, value);
                                      },
                                      this)
               },
               {
                   title:  "Prefix",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "Key",
                   width:  "200px",
                   render: Format.formatKey
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Created",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Value",
                   width:  "400px",
                   render: Format.formatValue
               }
           ];
};

RoutesTab.prototype.getRoutesAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("RoutesAnnotations",
                                                         "Are you sure you want to delete the route's selected annotations?",
                                                         "Delete",
                                                         "Deleting Route Annotation",
                                                         Constants.URL__ROUTES,
                                                         "");
                                  },
                                  this)
               }
           ];
};


RoutesTab.prototype.getRoutesSharesColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("RoutesShares"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox("RoutesShares", item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "100px",
                   render: function(name, type, row)
                           {
                               var spaceName = Format.formatSpaceName(name, type);

                               if (Format.doFormatting(type))
                               {
                                   return "<a class='tableLink' onclick='AdminUI.showSpaces(\"" +
                                          row[2] +
                                          "\")'>" +
                                          spaceName +
                                          "</a><img onclick='RoutesTab.prototype.displayRouteShareSpaceDetail(event, \"" +
                                          row[5] +
                                          "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                               }

                               return spaceName;
                           }
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Name",
                   width:  "100px",
                   render: function(name, type, row)
                           {
                              var organizationName = Format.formatOrganizationName(name, type);

                              if ((organizationName != "") && (Format.doFormatting(type)))
                              {
                                 return "<a class='tableLink' onclick='AdminUI.showOrganizations(\"" +
                                        row[4] +
                                        "\")'>" +
                                        organizationName +
                                        "</a><img onclick='RoutesTab.prototype.displayRouteShareOrganizationDetail(event, \"" +
                                        row[5] +
                                        "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                              }

                              return organizationName;
                           }
                },
                {
                    title:  "GUID",
                    width:  "200px",
                    render: Format.formatString
                }
           ];
};

RoutesTab.prototype.getRoutesSharesActions = function()
{
    return [
               {
                   text:  "Unshare",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("RoutesShares",
                                                         "Are you sure you want to unshare the route from the selected spaces?",
                                                         "Unshare",
                                                         "Unsharing Route",
                                                         Constants.URL__ROUTES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

RoutesTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#RoutesLabelsTableContainer").hide();
    $("#RoutesAnnotationsTableContainer").hide();
    $("#RoutesSharesTableContainer").hide();
};

RoutesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 7);
};

RoutesTab.prototype.showDetails = function(table, objects, row)
{
    var annotations  = objects.annotations;
    var domain       = objects.domain;
    var labels       = objects.labels;
    var organization = objects.organization;
    var route        = objects.route;
    var routeShares  = objects.route_shares;
    var space        = objects.space;

    var first = true;

    if (row[1] != null)
    {
        if ((route.port != null) && (route.port !== 0))
        {
            this.addPropertyRow(table, "URI", Format.formatString(row[1]), first);
        }
        else
        {
            this.addURIRow(table, "URI", row[1], first);
        }

        first = false;
    }

    if ((route.host != null) && (route.host !== ""))
    {
        this.addPropertyRow(table, "Host", Format.formatString(route.host), first);
        first = false;
    }

    if (domain != null)
    {
        this.addFilterRow(table, "Domain", Format.formatStringCleansed(domain.name), domain.guid, AdminUI.showDomains, first);
        this.addPropertyRow(table, "Domain GUID", Format.formatString(domain.guid));
        first = false;
    }

    if ((route.port != null) && (route.port !== 0))
    {
        this.addPropertyRow(table, "Port", Format.formatNumber(route.port), first);
        first = false;
    }

    if ((route.path != null) && (route.path !== ""))
    {
        this.addPropertyRow(table, "Path", Format.formatString(route.path), first);
        first = false;
    }

    if (route.vip_offset != null)
    {
        this.addPropertyRow(table, "VIP Offset", Format.formatNumber(route.vip_offset), first);
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "GUID", Format.formatString(route.guid), objects, first);

    this.addPropertyRow(table, "Created", Format.formatDateString(route.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, route.updated_at);
    this.addFilterRowIfValue(table, "Events", Format.formatNumber, row[10], route.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Route Mappings", Format.formatNumber, row[11], route.guid, AdminUI.showRouteMappings);
    this.addFilterRowIfValue(table, "Route Bindings", Format.formatNumber, row[12], route.guid, AdminUI.showRouteBindings);
    this.addRowIfValue(this.addPropertyRow, table, "Route Shares", Format.formatNumber, row[13]);

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

    if ((labels != null) && (labels.length > 0))
    {
        var labelsTableData = [];

        for (var labelIndex = 0; labelIndex < labels.length; labelIndex++)
        {
            var wrapper = labels[labelIndex];
            var label   = wrapper.label;

            var path = label.resource_guid + "/metadata/labels/" + encodeURIComponent(label.key_name);
            if (label.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(label.key_prefix);
            }

            var labelRow = [];

            labelRow.push(path);
            labelRow.push(label.key_prefix);
            labelRow.push(label.key_name);
            labelRow.push(label.guid);
            labelRow.push(wrapper.created_at_rfc3339);
            labelRow.push(wrapper.updated_at_rfc3339);
            labelRow.push(label.value);

            labelsTableData.push(labelRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#RoutesLabelsTableContainer").show();

        this.routesLabelsTable.api().clear().rows.add(labelsTableData).draw();
    }

    if ((annotations != null) && (annotations.length > 0))
    {
        var annotationsTableData = [];

        for (var annotationIndex = 0; annotationIndex < annotations.length; annotationIndex++)
        {
            var wrapper    = annotations[annotationIndex];
            var annotation = wrapper.annotation;

            var path = annotation.resource_guid + "/metadata/annotations/" + encodeURIComponent(annotation.key);
            if (annotation.key_prefix != null)
            {
                path += "?prefix=" + encodeURIComponent(annotation.key_prefix);
            }

            var annotationRow = [];

            annotationRow.push(path);
            annotationRow.push(annotation.key_prefix);
            annotationRow.push(annotation.key);
            annotationRow.push(annotation.guid);
            annotationRow.push(wrapper.created_at_rfc3339);
            annotationRow.push(wrapper.updated_at_rfc3339);
            annotationRow.push(annotation.value);

            annotationsTableData.push(annotationRow);
        }

        // Have to show the table prior to populating for its sizing to work correctly.
        $("#RoutesAnnotationsTableContainer").show();

        this.routesAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }

    if ((routeShares != null) && (routeShares.length > 0))
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#RoutesSharesTableContainer").show();

        // Ensure header check box cleared
        $("#RoutesSharesTableContainer").find(".headerCheckBox").each(function(index, value)
                                                                              {
                                                                                  if (value.checked == true)
                                                                                  {
                                                                                      value.checked = false;
                                                                                  }
                                                                              });

        var routesSharesTableData = [];

        for (var routeShareIndex = 0; routeShareIndex < routeShares.length; routeShareIndex++)
        {
            var share = routeShares[routeShareIndex];
            var space = share.space
            var organization = share.organization

            var routeShareRow = [];

            routeShareRow.push(route.guid + "/spaces/" + space.guid);
            routeShareRow.push(space.name);
            routeShareRow.push(space.guid);
            if (organization != null)
            {
                routeShareRow.push(organization.name)
                routeShareRow.push(organization.guid)
            }
            else
            {
                routeShareRow.push(null)
                routeShareRow.push(null)
            }

            // Need both the index and the actual object in the table
            routeShareRow.push(routeShareIndex);
            routeShareRow.push(space);
            routeShareRow.push(organization);

            routesSharesTableData.push(routeShareRow);
        }

        this.routesSharesTable.api().clear().rows.add(routesSharesTableData).draw();
    }
};

RoutesTab.prototype.displayRouteShareSpaceDetail = function(event, rowIndex)
{
    var row = $("#RoutesSharesTable").DataTable().row(rowIndex).data();

    var space = row[6];

    Utilities.windowOpen(space);

    event.stopPropagation();

    return false;
};

RoutesTab.prototype.displayRouteShareOrganizationDetail = function(event, rowIndex)
{
    var row = $("#RoutesSharesTable").DataTable().row(rowIndex).data();

    var organization = row[7];

    Utilities.windowOpen(organization);

    event.stopPropagation();

    return false;
};

