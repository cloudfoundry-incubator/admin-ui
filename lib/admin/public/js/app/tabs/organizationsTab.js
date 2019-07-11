
function OrganizationsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__ORGANIZATIONS, Constants.URL__ORGANIZATIONS_VIEW_MODEL);
}

OrganizationsTab.prototype = new Tab();

OrganizationsTab.prototype.constructor = OrganizationsTab;

OrganizationsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.organizationsLabelsTable = Table.createTable("OrganizationsLabels", this.getOrganizationsLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getOrganizationsLabelsActions(), Constants.FILENAME__ORGANIZATION_LABELS, null, null);

    this.organizationsAnnotationsTable = Table.createTable("OrganizationsAnnotations", this.getOrganizationsAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getOrganizationsAnnotationsActions(), Constants.FILENAME__ORGANIZATION_ANNOTATIONS, null, null);
};

OrganizationsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

OrganizationsTab.prototype.getColumns = function()
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
                   render: Format.formatOrganizationName
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:  "Status",
                   width:  "80px",
                   render: Format.formatOrganizationStatus
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
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Events Target",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Spaces",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Organization Roles",
                   width:     "90px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Space Roles",
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
                   title:  "Quota",
                   width:  "90px",
                   render: Format.formatQuotaName
               },
               {
                   title:     "Space Quotas",
                   width:     "90px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Domains",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Private Service Brokers",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Service Plan Visibilities",
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
                   title:  "Default Name",
                   width:  "100px",
                   render: Format.formatIsolationSegmentName
               },
               {
                   title:  "Default GUID",
                   width:  "200px",
                   render: Format.formatString
               },
               {
                   title:     "Related",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

OrganizationsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Create",
                   click: $.proxy(function()
                                  {
                                      this.createOrganization();
                                  },
                                  this)
               },
               {
                   text:  "Rename",
                   click: $.proxy(function()
                                  {
                                      this.renameSingleChecked(this.id,
                                                               "Rename Organization",
                                                               "Managing Organizations",
                                                               Constants.URL__ORGANIZATIONS);
                                  },
                                  this)
               },
               {
                   text:  "Set Quota",
                   click: $.proxy(function()
                                  {
                                      this.setOrganizationsQuotas();
                                  },
                                  this)
               },
               {
                   text:  "Activate",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Organizations",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "",
                                                         '{"status":"active"}');
                                  },
                                  this)
               },
               {
                   text:  "Suspend",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Organizations",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "",
                                                         '{"status":"suspended"}');
                                  },
                                  this)
               },
               {
                   text:  "Remove Default Isolation Segment",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to remove the selected organizations' default isolation segments?",
                                                         "Remove",
                                                         "Managing Organizations",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "/default_isolation_segment");
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected organizations?",
                                                         "Delete",
                                                         "Deleting Organizations",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Delete Recursive",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected organizations and their contained spaces, space quotas, applications, routes, route mappings, private domains, private service brokers, service instances, service instance shares, service bindings, service keys and route bindings?",
                                                         "Delete Recursive",
                                                         "Deleting Organizations and their Contents",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "?recursive=true");
                                  },
                                  this)
               }
           ];
};

OrganizationsTab.prototype.getOrganizationsLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("OrganizationsLabels"),
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

                                          return this.formatCheckbox("OrganizationsLabels", text, value);
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

OrganizationsTab.prototype.getOrganizationsLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("OrganizationsLabels",
                                                         "Are you sure you want to delete the organization's selected labels?",
                                                         "Delete",
                                                         "Deleting Organization Label",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

OrganizationsTab.prototype.getOrganizationsAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("OrganizationsAnnotations"),
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

                                          return this.formatCheckbox("OrganizationsAnnotations", text, value);
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

OrganizationsTab.prototype.getOrganizationsAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("OrganizationsAnnotations",
                                                         "Are you sure you want to delete the organization's selected annotations?",
                                                         "Delete",
                                                         "Deleting Organization Annotation",
                                                         Constants.URL__ORGANIZATIONS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

OrganizationsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#OrganizationsLabelsTableContainer").hide();
    $("#OrganizationsAnnotationsTableContainer").hide();
};

OrganizationsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

OrganizationsTab.prototype.showDetails = function(table, objects, row)
{
    var annotations             = objects.annotations;
    var defaultIsolationSegment = objects.default_isolation_segment;
    var labels                  = objects.labels;
    var organization            = objects.organization;
    var quotaDefinition         = objects.quota_definition;

    var target = organization.name + "/";

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(organization.name), objects, true);

    this.addPropertyRow(table, "GUID", Format.formatString(organization.guid));

    if (organization.status != null)
    {
        this.addPropertyRow(table, "Status", Format.formatString(organization.status).toUpperCase());
    }

    this.addPropertyRow(table, "Created", Format.formatDateString(organization.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, organization.updated_at);
    this.addPropertyRow(table, "Billing Enabled", Format.formatBoolean(organization.billing_enabled));
    this.addFilterRowIfValue(table, "Events", Format.formatNumber, row[6], organization.guid, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Events Target", Format.formatNumber, row[7], target, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Spaces", Format.formatNumber, row[8], target, AdminUI.showSpaces);
    this.addFilterRowIfValue(table, "Organization Roles", Format.formatNumber, row[9], organization.guid, AdminUI.showOrganizationRoles);
    this.addFilterRowIfValue(table, "Space Roles", Format.formatNumber, row[10], target, AdminUI.showSpaceRoles);
    this.addFilterRowIfValue(table, "Default Users", Format.formatNumber, row[11], target, AdminUI.showUsers);

    if (quotaDefinition != null)
    {
        this.addFilterRow(table, "Quota", Format.formatStringCleansed(quotaDefinition.name), quotaDefinition.guid, AdminUI.showQuotas);
        this.addPropertyRow(table, "Quota GUID", Format.formatString(quotaDefinition.guid));
    }

    this.addFilterRowIfValue(table, "Space Quotas", Format.formatNumber, row[13], organization.guid, AdminUI.showSpaceQuotas);
    this.addFilterRowIfValue(table, "Domains", Format.formatNumber, row[14], organization.name, AdminUI.showDomains);
    this.addFilterRowIfValue(table, "Private Service Brokers", Format.formatNumber, row[15], target, AdminUI.showServiceBrokers);
    this.addFilterRowIfValue(table, "Service Plan Visibilities", Format.formatNumber, row[16], organization.guid, AdminUI.showServicePlanVisibilities);
    this.addFilterRowIfValue(table, "Security Groups", Format.formatNumber, row[17], target, AdminUI.showSecurityGroupsSpaces);
    this.addFilterRowIfValue(table, "Staging Security Groups", Format.formatNumber, row[18], target, AdminUI.showStagingSecurityGroupsSpaces);
    this.addFilterRowIfValue(table, "Total Routes", Format.formatNumber, row[19], target, AdminUI.showRoutes);
    this.addRowIfValue(this.addPropertyRow, table, "Used Routes", Format.formatNumber, row[20]);
    this.addRowIfValue(this.addPropertyRow, table, "Unused Routes", Format.formatNumber, row[21]);
    this.addFilterRowIfValue(table, "Total Apps", Format.formatNumber, row[22], target, AdminUI.showApplications);
    this.addFilterRowIfValue(table, "Instances Used", Format.formatNumber, row[23], target, AdminUI.showApplicationInstances);
    this.addFilterRowIfValue(table, "Services Used", Format.formatNumber, row[24], target, AdminUI.showServiceInstances);
    this.addFilterRowIfValue(table, "Tasks Used", Format.formatNumber, row[25], target, AdminUI.showTasks);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Used", Format.formatNumber, row[26]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Used", Format.formatNumber, row[27]);
    this.addRowIfValue(this.addPropertyRow, table, "CPU Used",  Format.formatNumber, row[28]);
    this.addRowIfValue(this.addPropertyRow, table, "Memory Reserved", Format.formatNumber, row[29]);
    this.addRowIfValue(this.addPropertyRow, table, "Disk Reserved",   Format.formatNumber, row[30]);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Started Apps", Format.formatNumber, row[31]);
    this.addRowIfValue(this.addPropertyRow, table, "Desired Stopped Apps", Format.formatNumber, row[32]);
    this.addRowIfValue(this.addPropertyRow, table, "Started Apps", Format.formatNumber, row[33]);
    this.addRowIfValue(this.addPropertyRow, table, "Stopped Apps", Format.formatNumber, row[34]);
    this.addRowIfValue(this.addPropertyRow, table, "Pending Apps",  Format.formatNumber, row[35]);
    this.addRowIfValue(this.addPropertyRow, table, "Staged Apps",  Format.formatNumber, row[36]);
    this.addRowIfValue(this.addPropertyRow, table, "Failed Apps",  Format.formatNumber, row[37]);

    if (defaultIsolationSegment != null)
    {
        this.addFilterRow(table, "Default Isolation Segment", Format.formatStringCleansed(defaultIsolationSegment.name), defaultIsolationSegment.guid, AdminUI.showIsolationSegments);
        this.addPropertyRow(table, "Default Isolation Segment GUID", Format.formatString(defaultIsolationSegment.guid));
    }

    this.addFilterRowIfValue(table, "Related Isolation Segments", Format.formatNumber, row[40], organization.guid, AdminUI.showOrganizationsIsolationSegments);

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
        $("#OrganizationsLabelsTableContainer").show();

        this.organizationsLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#OrganizationsAnnotationsTableContainer").show();

        this.organizationsAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};

OrganizationsTab.prototype.createOrganization = function()
{
    var dialogContentDiv = $("<div></div>");
    dialogContentDiv.append($("<label>Name: </label>"));
    dialogContentDiv.append($("<input type='text' id='organizationName'>"));

    AdminUI.showModalDialogAction("Create Organization",
                                  dialogContentDiv,
                                  "Create",
                                  "organizationName",
                                  $.proxy(function()
                                          {
                                              var organizationName = $("#organizationName").val();
                                              if (!organizationName)
                                              {
                                                  alert("Please input the name first!");
                                                  return;
                                              }

                                              this.doCreateOrganization(organizationName);
                                          }, 
                                          this));
};

OrganizationsTab.prototype.setOrganizationsQuotas = function()
{
    var organizations = this.getChecked(this.id);

    if ((!organizations) || (organizations.length == 0))
    {
        return;
    }

    var deferred = $.ajax({
                              type:     "GET",
                              url:      Constants.URL__QUOTAS_VIEW_MODEL,
                              dataType: "json"
                          });

    deferred.done($.proxy(function(result, status)
    {
        if (result.items.connected)
        {
            var quotas = result.items.items;
            var dialogContentDiv = $("<div></div>");
            dialogContentDiv.append($("<label>Select a quota: </label>"));

            var selector = $("<select id='quotaSelector'></select>");

            for (var quotaIndex = 0; quotaIndex < quotas.length; quotaIndex++)
            {
                var quotaName = Format.formatStringCleansed(quotas[quotaIndex][1]);
                var quotaGUID = quotas[quotaIndex][2];
                selector.append($("<option value='" + quotaGUID + "'>" + quotaName + "</option>"));
            }

            dialogContentDiv.append(selector);

            AdminUI.showModalDialogAction("Set Organization Quota",
                                          dialogContentDiv,
                                          "Set",
                                          "quotaSelector",
                                          $.proxy(function()
                                                  {
                                                      var controlMessage = '{"quota_definition_guid":"' + $("#quotaSelector").val() + '"}';

                                                      this.update("Managing Organizations",
                                                                  Constants.URL__ORGANIZATIONS,
                                                                  "",
                                                                  organizations,
                                                                  controlMessage);
                                                  },
                                                  this));
        }
        else
        {
            var error = "Error retrieving quota definitions";

            if (result.items.error)
            {
                error += ":<br/><br/>" + result.items.error;
            }

            AdminUI.showModalDialogError(error);
        }
    }, this));

    deferred.fail(function(xhr, status, error)
                  {
                      if (xhr.status == 303)
                      {
                          window.location.href = Constants.URL__LOGIN;
                      }
                      else
                      {
                          AdminUI.showModalDialogError("Error retrieving quota definitions:<br/><br/>" + error);
                      }
                  });
};

OrganizationsTab.prototype.doCreateOrganization = function(organizationName)
{
    AdminUI.showModalDialogProgress("Managing Organizations");

    var deferred = $.ajax({
                              type:        "POST",
                              url:         Constants.URL__ORGANIZATIONS,
                              contentType: "application/json; charset=utf-8",
                              dataType:    "json",
                              data:        '{"name":"' + organizationName + '"}'
                          });

    deferred.done(function(response, status)
                  {
                      AdminUI.showModalDialogSuccess();
                  });

    deferred.fail(function(xhr, status, error)
                  {
                      AdminUI.showModalDialogErrorTable([{
                                                             label: organizationName,
                                                             xhr:   xhr
                                                         }]);
    });

    deferred.always(function(xhr, status, error)
                    {
                        AdminUI.refresh();
                    });
};
