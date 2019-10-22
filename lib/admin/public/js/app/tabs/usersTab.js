
function UsersTab(id)
{
    Tab.call(this, id, Constants.FILENAME__USERS, Constants.URL__USERS_VIEW_MODEL);
}

UsersTab.prototype = new Tab();

UsersTab.prototype.constructor = UsersTab;

UsersTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.usersLabelsTable = Table.createTable("UsersLabels", this.getUsersLabelsColumns(), [[1, "asc"], [2, "asc"]], null, this.getUsersLabelsActions(), Constants.FILENAME__USER_LABELS, null, null);

    this.usersAnnotationsTable = Table.createTable("UsersAnnotations", this.getUsersAnnotationsColumns(), [[1, "asc"], [2, "asc"]], null, this.getUsersAnnotationsActions(), Constants.FILENAME__USER_ANNOTATIONS, null, null);
};

UsersTab.prototype.getInitialSort = function()
{
    return [[1, "asc"], [2, "asc"]];
};

UsersTab.prototype.getColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader(this.id),
                   type:      "html",
                   width:     "2px",
                   orderable: false,
                   render:    $.proxy(function(value, type, item)
                                      {
                                          return this.formatCheckbox(this.id, item[2], value);
                                      },
                                      this)
               },
               {
                   title:  "Identity Zone",
                   width:  "300px",
                   render: Format.formatIdentityString
               },
               {
                   title:  "Username",
                   width:  "200px",
                   render: Format.formatUserString
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
                   title:  "Last Successful Logon",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Previous Successful Logon",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Password Updated",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:  "Password Change Required",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Email",
                   width:  "200px",
                   render: Format.formatUserString
               },
               {
                   title:  "Family Name",
                   width:  "200px",
                   render: Format.formatUserString
               },
               {
                   title:  "Given Name",
                   width:  "200px",
                   render: Format.formatUserString
               },
               {
                   title:  "Phone Number",
                   width:  "200px",
                   render: Format.formatUserString
               },
               {
                   title:  "Active",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:  "Verified",
                   width:  "10px",
                   render: Format.formatBoolean
               },
               {
                   title:     "Version",
                   width:     "100px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Events",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Groups",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Approvals",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Revocable Tokens",
                   width:     "70px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Count",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Valid Until",
                   width:  "180px",
                   render: Format.formatString
               },
               {
                   title:     "Total",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Auditor",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Billing Manager",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Manager",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "User",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Total",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Auditor",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Developer",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:     "Manager",
                   width:     "80px",
                   className: "cellRightAlign",
                   render:    Format.formatNumber
               },
               {
                   title:  "Default Target",
                   width:  "200px",
                   render: Format.formatTarget
               }
           ];
};


UsersTab.prototype.getActions = function()
{
    return [
               {
                   text:  "Activate",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Users",
                                                         Constants.URL__USERS,
                                                         "",
                                                         '{"active":true}');
                                  },
                                  this)
               },
               {
                   text:  "Deactivate",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Users",
                                                         Constants.URL__USERS,
                                                         "",
                                                         '{"active":false}');
                                  },
                                  this)
               },
               {
                   text:  "Verify",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Users",
                                                         Constants.URL__USERS,
                                                         "",
                                                         '{"verified":true}');
                                  },
                                  this)
               },
               {
                   text:  "Unverify",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Users",
                                                         Constants.URL__USERS,
                                                         "",
                                              '{"verified":false}');
                                  },
                                  this)
               },
               {
                   text:  "Unlock",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Users",
                                                         Constants.URL__USERS,
                                                         "/status",
                                                         '{"locked":false}');
                                  },
                                  this)
               },
               {
                   text:  "Require Password Change",
                   click: $.proxy(function()
                                  {
                                      this.updateChecked(this.id,
                                                         "Managing Users",
                                                         Constants.URL__USERS,
                                                         "/status",
                                                         '{"passwordChangeRequired":true}');
                                  },
                                  this)
               },
               {
                   text:  "Revoke Tokens",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to revoke the selected users' tokens?",
                                                         "Revoke",
                                                         "Revoking User Tokens",
                                                         Constants.URL__USERS,
                                                         "/tokens");
                                  },
                                  this)
               },
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked(this.id,
                                                         "Are you sure you want to delete the selected users?",
                                                         "Delete",
                                                         "Deleting Users",
                                                         Constants.URL__USERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

UsersTab.prototype.getUsersLabelsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("UsersLabels"),
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

                                          return this.formatCheckbox("UsersLabels", text, value);
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

UsersTab.prototype.getUsersLabelsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("UsersLabels",
                                                         "Are you sure you want to delete the user's selected labels?",
                                                         "Delete",
                                                         "Deleting User Label",
                                                         Constants.URL__USERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

UsersTab.prototype.getUsersAnnotationsColumns = function()
{
    return [
               {
                   title:     Tab.prototype.formatCheckboxHeader("UsersAnnotations"),
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

                                          return this.formatCheckbox("UsersAnnotations", text, value);
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

UsersTab.prototype.getUsersAnnotationsActions = function()
{
    return [
               {
                   text:  "Delete",
                   click: $.proxy(function()
                                  {
                                      this.deleteChecked("UsersAnnotations",
                                                         "Are you sure you want to delete the user's selected annotations?",
                                                         "Delete",
                                                         "Deleting User Annotation",
                                                         Constants.URL__USERS,
                                                         "");
                                  },
                                  this)
               }
           ];
};

UsersTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);

    $("#UsersLabelsTableContainer").hide();
    $("#UsersAnnotationsTableContainer").hide();
};

UsersTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 3);
};

UsersTab.prototype.showDetails = function(table, objects, row)
{
    var annotations  = objects.annotations;
    var identityZone = objects.identity_zone;
    var labels       = objects.labels;
    var organization = objects.organization;
    var requestCount = objects.request_count;
    var space        = objects.space;
    var user         = objects.user_uaa;

    var first = true;

    if (identityZone != null)
    {
        this.addFilterRow(table, "Identity Zone", Format.formatStringCleansed(identityZone.name), identityZone.id, AdminUI.showIdentityZones, first);
        this.addPropertyRow(table, "Identity Zone ID", Format.formatString(identityZone.id));
        first = false;
    }

    this.addJSONDetailsLinkRow(table, "Username", Format.formatString(user.username), objects, first);
    this.addPropertyRow(table, "GUID", Format.formatString(user.id));
    this.addPropertyRow(table, "Created", Format.formatDateString(user.created));
    this.addRowIfValue(this.addPropertyRow, table, "Updated", Format.formatDateString, user.lastmodified);
    this.addRowIfValue(this.addPropertyRow, table, "Last Successful Logon", Format.formatDateNumber, user.last_logon_success_time);
    this.addRowIfValue(this.addPropertyRow, table, "Previous Successful Logon", Format.formatDateNumber, user.previous_logon_success_time);
    this.addRowIfValue(this.addPropertyRow, table, "Password Updated", Format.formatDateString, user.passwd_lastmodified);
    this.addRowIfValue(this.addPropertyRow, table, "Password Change Required", Format.formatBoolean, user.passwd_change_required);

    var email = "mailto:" + Format.formatString(user.email);
    var emailLink = document.createElement("a");
    $(emailLink).attr("target", "_blank");
    $(emailLink).attr("href", email);
    $(emailLink).addClass("tableLink");
    $(emailLink).html(email);

    this.addRow(table, "Email", emailLink, false);

    this.addRowIfValue(this.addPropertyRow, table, "Family Name", Format.formatString, user.familyname);
    this.addRowIfValue(this.addPropertyRow, table, "Given Name", Format.formatString, user.givenname);
    this.addRowIfValue(this.addPropertyRow, table, "Phone Number", Format.formatString, user.phonenumber);
    this.addRowIfValue(this.addPropertyRow, table, "Active", Format.formatBoolean, user.active);
    this.addRowIfValue(this.addPropertyRow, table, "Verified", Format.formatBoolean, user.verified);
    this.addPropertyRow(table, "Version", Format.formatNumber(user.version));
    this.addFilterRowIfValue(table, "Events", Format.formatNumber, row[17], user.id, AdminUI.showEvents);
    this.addFilterRowIfValue(table, "Groups", Format.formatNumber, row[18], user.id, AdminUI.showGroupMembers);
    this.addFilterRowIfValue(table, "Approvals", Format.formatNumber, row[19], user.id, AdminUI.showApprovals);
    this.addFilterRowIfValue(table, "Revocable Tokens", Format.formatNumber, row[20], user.id, AdminUI.showRevocableTokens);
    this.addRowIfValue(this.addPropertyRow, table, "Requests Count", Format.formatNumber, row[21]);

    if (requestCount != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Requests Count Valid Until", Format.formatDateString, requestCount.valid_until);
    }

    this.addFilterRowIfValue(table, "Organization Total Roles", Format.formatNumber, row[23], user.id, AdminUI.showOrganizationRoles);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Auditor Roles", Format.formatNumber, row[24]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Billing Manager Roles", Format.formatNumber, row[25]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization Manager Roles", Format.formatNumber, row[26]);
    this.addRowIfValue(this.addPropertyRow, table, "Organization User Roles", Format.formatNumber, row[27]);
    this.addFilterRowIfValue(table, "Space Total Roles", Format.formatNumber, row[28], user.id, AdminUI.showSpaceRoles);
    this.addRowIfValue(this.addPropertyRow, table, "Space Auditor Roles", Format.formatNumber, row[29]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Developer Roles", Format.formatNumber, row[30]);
    this.addRowIfValue(this.addPropertyRow, table, "Space Manager Roles", Format.formatNumber, row[31]);

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
        $("#UsersLabelsTableContainer").show();

        this.usersLabelsTable.api().clear().rows.add(labelsTableData).draw();
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
        $("#UsersAnnotationsTableContainer").show();

        this.usersAnnotationsTable.api().clear().rows.add(annotationsTableData).draw();
    }
};
