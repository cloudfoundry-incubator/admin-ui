
function DomainsTab(id)
{
    Tab.call(this, id, Constants.FILENAME__DOMAINS, Constants.URL__DOMAINS_VIEW_MODEL);
}

DomainsTab.prototype = new Tab();

DomainsTab.prototype.constructor = DomainsTab;

DomainsTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.domainsLabelsTable = Table.createTable("DomainsLabels", this.getDomainsLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getDomainsLabelsActions(), Constants.FILENAME__DOMAIN_LABELS, null, null);

    this.domainsAnnotationsTable = Table.createTable("DomainsAnnotations", this.getDomainsAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getDomainsAnnotationsActions(), Constants.FILENAME__DOMAIN_ANNOTATIONS, null, null);

    this.domainsOrganizationsTable = Table.createTable("DomainsOrganizations", this.getDomainsOrganizationsColumns(), [[1, "asc"]], null, this.getDomainsOrganizationsActions(), Constants.FILENAME__DOMAIN_ORGANIZATIONS, null, null);
};

DomainsTab.prototype.getInitialSort = function()
{
    return [[1, "asc"]];
};

DomainsTab.prototype.getColumns = function()
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
                   width:  "200px",
                   render: Format.formatDomainName
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
                   title:  "Internal",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Shared",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Owning Organization",
                   width:  "200px",
                   render: Format.formatOrganizationName
               },
               {
                   title:     "Private Shared Organizations",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Routes",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               }
           ];
};

DomainsTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected domains?",
                                                         "Delete",
                                                         "Deleting Domains",
                                                         Constants.URL__DOMAINS,
                                                         "");
                                  },
                                  this)
               },
               {
                   text:  "Delete Recursive",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected domains and their associated routes, route mappings and route bindings?",
                                                         "Delete Recursive",
                                                         "Deleting Domains and Associated Routes and Route Bindings",
                                                         Constants.URL__DOMAINS,
                                                         "?recursive=true");
                                  },
                                  this)
               }
           ];
};

DomainsTab.prototype.getDomainsLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("DomainsLabels"),
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

                                          return this.formatCheckbox("DomainsLabels", text, value);
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

DomainsTab.prototype.getDomainsLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("DomainsLabels",
                                                         "Are you sure you want to delete the domain's selected labels?",
                                                         "Delete",
                                                         "Deleting Domain Label",
                                                         Constants.URL__DOMAINS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

DomainsTab.prototype.getDomainsAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("DomainsAnnotations"),
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

                                          return this.formatCheckbox("DomainsAnnotations", text, value);
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

DomainsTab.prototype.getDomainsAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("DomainsAnnotations",
                                                         "Are you sure you want to delete the domain's selected annotations?",
                                                         "Delete",
                                                         "Deleting Domain Annotation",
                                                         Constants.URL__DOMAINS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

DomainsTab.prototype.getDomainsOrganizationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("DomainsOrganizations"),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox("DomainsOrganizations", item[1], value);
                                      },
                                      this)
               },
               {
                   title:  "Organization",
                   width:  "100px",
                   render: function(name, type, row)
                           {
                               var privateSharedOrganizationName = Format.formatOrganizationName(name, type);

                               if (Format.doFormatting(type))
                               {
                                   return "<a class='tableLink' onclick='AdminUI.showOrganizations(\"" +
                                          row[1] +
                                          "\")'>" +
                                          privateSharedOrganizationName +
                                          "</a><img onclick='DomainsTab.prototype.displayPrivateSharedOrganizationDetail(event, \"" +
                                          row[3] +
                                          "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                               }

                               return privateSharedOrganizationName;
                           }
               },
               {
                   title:  "GUID",
                   width:  "200px",
                   render: Format.formatString
               }
           ];
};

DomainsTab.prototype.getDomainsOrganizationsActions = function()
{
    return [
               {
                   text:  "Unshare",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("DomainsOrganizations",
                                                         "Are you sure you want to unshare the domain from the selected organizations?",
                                                         "Unshare",
                                                         "Unsharing Private Domain",
                                                         Constants.URL__DOMAINS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

DomainsTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#DomainsLabelsTableContainer").hide();
    $("#DomainsAnnotationsTableContainer").hide();
    $("#DomainsOrganizationsTableContainer").hide();
};

DomainsTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 0);
};

DomainsTab.prototype.showDetails = function(table, objects, row)
{
    var annotations                = objects.annotations;
    var domain                     = objects.domain;
    var labels                     = objects.labels;
    var owningOrganization         = objects.owning_organization;
    var privateSharedOrganizations = objects.private_shared_organizations;

    this.addJSONDetailsLinkRow(table, "Name", Format.formatString(domain.name), objects, true);
    this.addPropertyRow(table, "GUID", Format.formatString(domain.guid));
    this.addPropertyRow(table, "Created", Format.formatDateString(domain.created_at));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, domain.updated_at);
    this.addRowIfValue(this.addPropertyRow, table, "Internal", Format.formatBoolean, domain.internal);
    this.addPropertyRow(table, "Shared", Format.formatBoolean(row[6]));

    if (owningOrganization != null)
    {
        this.addFilterRow(table, "Owning Organization", Format.formatStringCleansed(owningOrganization.name), owningOrganization.guid, AdminUI.showOrganizations);
        this.addPropertyRow(table, "Owning Organization GUID", Format.formatString(owningOrganization.guid));
    }

    this.addFilterRowIfValue(table, "Routes", Format.formatNumber, row[9], domain.name, AdminUI.showRoutes);

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
        $("#DomainsLabelsTableContainer").show();

        this.domainsLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#DomainsAnnotationsTableContainer").show();

        this.domainsAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }

    if ((privateSharedOrganizations != null) && (privateSharedOrganizations.length > 0))
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#DomainsOrganizationsTableContainer").show();

        // Ensure header check box cleared
        $("#DomainsOrganizationsTableContainer").find(".headerCheckBox").each(function(index, value)
                                                                              {
                                                                                  if (value.checked == true)
                                                                                  {
                                                                                      value.checked = false;
                                                                                  }
                                                                              });

        var domainsOrganizationsTableData = [];

        for (var privateSharedOrganizationIndex = 0; privateSharedOrganizationIndex < privateSharedOrganizations.length; privateSharedOrganizationIndex++)
        {
            var privateSharedOrganization = privateSharedOrganizations[privateSharedOrganizationIndex];

            var privateSharedOrganizationRow = [];

            privateSharedOrganizationRow.push(domain.guid + "/false/" + privateSharedOrganization.guid);
            privateSharedOrganizationRow.push(privateSharedOrganization.name);
            privateSharedOrganizationRow.push(privateSharedOrganization.guid);

            // Need both the index and the actual object in the table
            privateSharedOrganizationRow.push(privateSharedOrganizationIndex);
            privateSharedOrganizationRow.push(privateSharedOrganization);

            domainsOrganizationsTableData.push(privateSharedOrganizationRow);
        }

        this.domainsOrganizationsTable.api().clear().rows.add(domainsOrganizationsTableData).draw();
    }
};

DomainsTab.prototype.displayPrivateSharedOrganizationDetail = function(event, rowIndex)
{
    var row = $("#DomainsOrganizationsTable").DataTable().row(rowIndex).data();

    var privateSharedOrganization = row[4];

    Utilities.windowOpen(privateSharedOrganization);

    event.stopPropagation();

    return false;
};
