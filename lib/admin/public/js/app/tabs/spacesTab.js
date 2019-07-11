
function SpacesTab(id)
{
    Tab.call(this, id, Constants.FILENAME__SPACES, Constants.URL__SPACES_VIEW_MODEL);
}

SpacesTab.prototype = new Tab();

SpacesTab.prototype.constructor = SpacesTab;

SpacesTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.spacesLabelsTable = Table.createTable("SpacesLabels", this.getSpacesLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getSpacesLabelsActions(), Constants.FILENAME__SPACE_LABELS, null, null);

    this.spacesAnnotationsTable = Table.createTable("SpacesAnnotations", this.getSpacesAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getSpacesAnnotationsActions(), Constants.FILENAME__SPACE_ANNOTATIONS, null, null);
};

SpacesTab.prototype.getInitialSort = function()
{
    return [[3, "asc"]];
};

SpacesTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Name",
                   width:  "100px",
                   render: Format.formatSpaceName
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
                   title:  "SSH Allowed",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Events Target",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Roles",
                   width:     "90px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Default Users",
                   width:     "90px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Space Quota",
                   width:  "90px",
                   render: Format.formatQuotaName
               },
               {
                   title:     "Private Service Brokers",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Security Groups",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Staging Security Groups",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Total",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Used",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Unused",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Apps",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Instances",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Services",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Tasks",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "% CPU",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Memory",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Disk",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Started",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Stopped",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Started",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Stopped",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Pending",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Staged",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Failed",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Name",
                   width:  "100px",
                   render: Format.formatIsolationSegmentName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
           ];
};

SpacesTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Space",
                                                               "Managing Spaces",
                                                               Constants.URL__SPACES);
                                  },
                                  this)
               },
               {
                   text:  "Allow SSH",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Spaces",
                                                         Constants.URL__SPACES,
                                                         "",
                                                         '{"allow_ssh":true}');
                                  },
                                  this)
               },
               {
                   text:  "Disallow SSH",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Spaces",
                                                         Constants.URL__SPACES,
                                                         "",
                                                         '{"allow_ssh":false}');
                                  },
                                  this)
               },
               {
                   text:  "Remove Isolation Segment",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to remove the selected spaces' isolation segments?",
                                                         "Remove",
                                                         "Managing Spaces",
                                                         Constants.URL__SPACES,
                                                         "/isolation_segment");
                                  },
                                  this)
               },
               {
                   text:  "Delete Unmapped Routes",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected spaces' unmapped routes?",
                                                         "Delete",
                                                         "Managing Spaces",
                                                         Constants.URL__SPACES,
                                                         "/unmapped_routes");
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected spaces?",
                                                         "Delete",
                                                         "Deleting Spaces",
                                                         Constants.URL__SPACES,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Delete Recursive",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected spaces and their contained applications, routes, route mappings, private service brokers, service instances, service instance shares, service bindings, service keys and route bindings?",
                                                         "Delete Recursive",
                                                         "Deleting Spaces and their Contents",
                                                         Constants.URL__SPACES,
                                                         "?recursive=true");
                                  },
                                  this)
               }
           ];
};

SpacesTab.prototype.getSpacesLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("SpacesLabels"),
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

                                          return this.formatCheckbox("SpacesLabels", text, value);
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

SpacesTab.prototype.getSpacesLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("SpacesLabels",
                                                         "Are you sure you want to delete the space's selected labels?",
                                                         "Delete",
                                                         "Deleting Space Label",
                                                         Constants.URL__SPACES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

SpacesTab.prototype.getSpacesAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("SpacesAnnotations"),
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

                                          return this.formatCheckbox("SpacesAnnotations", text, value);
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

SpacesTab.prototype.getSpacesAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("SpacesAnnotations",
                                                         "Are you sure you want to delete the space's selected annotations?",
                                                         "Delete",
                                                         "Deleting Space Annotation",
                                                         Constants.URL__SPACES,
                                                         "");
                                  },
                                  this)
               }
           ];
};

SpacesTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#SpacesLabelsTableContainer").hide();
    $("#SpacesAnnotationsTableContainer").hide();
};

SpacesTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

SpacesTab.prototype.showDetails = function(table, objects, row)
{
    var annotations      = objects.annotations;
    var isolationSegment = objects.isolation_segment;
    var labels           = objects.labels;
    var organization     = objects.organization;
    var space            = objects.space;
    var spaceQuota       = objects.space_quota_definition;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(space.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(space.guid));

    if (organization != null)
    {
        this.addFilterRow(table, "Organization", Format.formatStringCleansed(organization.name), organization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Organization GUID", Format.formatString(organization.guid));
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(space.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, space.updated_at);
    this.addPropertyRow(table, "SSH Allowed", Format.formatBoolean(row[6]));
    this.addFilterRowIfValue(table, "Events", Format.formatNumber, row[7], space.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Events Target", Format.formatNumber, row[8], Format.formatString(row[3]), AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Roles", Format.formatNumber, row[9], space.guid, AdminUI.showSpaceRoles);
    this.addFilterRowIfValue(table, "Default Users", Format.formatNumber, row[10], Format.formatString(row[3]), AdminUI.showUsers);

    if (spaceQuota != null)
    {
        this.addFilterRow(table, "Space Quota", Format.formatStringCleansed(spaceQuota.name), spaceQuota.guid, AdminUI.showSpaceQuotas);
        this.addPropertyRow(table, "Space Quota GUID", Format.formatString(spaceQuota.guid));
    }

    this.addFilterRowIfValue(table, "Private Service Brokers", Format.formatNumber, row[12], Format.formatString(row[3]), AdminUI.showServiceBrokers);
    this.addFilterRowIfValue(table, "Security Groups", Format.formatNumber, row[13], space.guid, AdminUI.showSecurityGroupsSpaces);
    this.addFilterRowIfValue(table, "Staging Security Groups", Format.formatNumber, row[14], space.guid, AdminUI.showStagingSecurityGroupsSpaces);
    this.addFilterRowIfValue(table, "Total Routes", Format.formatNumber, row[15], Format.formatString(row[3]), AdminUI.showRoutes);
    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[16]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[17]);
    this.addFilterRowIfValue(table, "Total Apps", Format.formatNumber, row[18], Format.formatString(row[3]), AdminUI.showApplications);
    this.addFilterRowIfValue(table, "Instances Used", Format.formatNumber, row[19], Format.formatString(row[3]), AdminUI.showApplicationInstances);
    this.addFilterRowIfValue(table, "Services Used", Format.formatNumber, row[20], Format.formatString(row[3]), AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Tasks Used", Format.formatNumber, row[21], Format.formatString(row[3]), AdminUI.showTasks);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used",     Format.formatNumber, row[22]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used",       Format.formatNumber, row[23]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",        Format.formatNumber, row[24]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[25]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[26]);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Started Apps", Format.formatNumber, row[27]);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Stopped Apps", Format.formatNumber, row[28]);
    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[29]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[30]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps", Format.formatNumber, row[31]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps", Format.formatNumber, row[32]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps", Format.formatNumber, row[33]);

    if (isolationSegment != null)
    {
        this.addFilterRow(table, "Isolation Segment", Format.formatStringCleansed(isolationSegment.name), isolationSegment.guid, AdminUI.showIsolationSegments);
        this.addPropertyRow(table, "Isolation Segment GUID", Format.formatString(isolationSegment.guid));
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
        $("#SpacesLabelsTableContainer").show();

        this.spacesLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#SpacesAnnotationsTableContainer").show();

        this.spacesAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
