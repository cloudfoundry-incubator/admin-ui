
var Format =
{
    raw: false,

    doFormatting: function(type)
    {
        if (Format.raw)
        {
            return false;
        }
        
        return ((type == null) || (type == "display"));
    },

    fixDateString: function(dateString)
    {
        dateString = dateString.replace(" +", "+");
        dateString = dateString.replace(" -", "-");

        var stringLength = dateString.length;

        if (stringLength > 2)
        {
            var colonIndex = stringLength - 2;

            if (dateString.charAt(colonIndex) != ":")
            {
                dateString = dateString.substring(0, colonIndex) + ":" + dateString.substring(colonIndex);
            }
        }

        if (dateString.charAt(10) != "T")
        {
            dateString = dateString.substring(0, 10) + "T" + dateString.substring(11);
        }

        return dateString;
    },

    formatApplicationName: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 30);
    },
    
    formatApplications: function(applications, type)
    {
        if (applications == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "";

            var first = true;

            for (var appIndex = 0; appIndex < applications.length; appIndex++)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    result += "<br/>";
                }

                var app = applications[appIndex];

                if (type == "display")
                {
                    result += "<span title=\"" + Format.replaceScriptQuotes(app) + "\">";

                    var sanitizedApp = Format.removeScriptInjection(app);
                    
                    if (sanitizedApp.length > 20)
                    {
                        result += sanitizedApp.substring(0, 20) + "...";
                    }
                    else
                    {
                        result += sanitizedApp;
                    }

                    result += "</span>";
                }
                else
                {
                    result += app;
                }
            }

            return result;
        }
        
        return applications;
    },

    formatAvailableCapacity: function(capacity, type)
    {
        if (capacity == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var color = "rgb(0, 190, 0)";

            if (capacity < 5)
            {
                color = "rgb(200, 0, 0)";
            }
            else if (capacity < 10)
            {
                color = "rgb(250, 100, 0)";
            }
            else if (capacity < 20)
            {
                color = "rgb(170, 160, 0)";
            }

            return "<span style='color: " + color + ";'>" + capacity + "</span>";
        }
        
        return capacity;
    },

    formatBoolean: function(value)
    {
        if (value == null)
        {
            return "";
        }
        
        return (value) ? "true" : "false";
    },

    formatBuildpacks: function(buildpacks, type)
    {
        if (buildpacks == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "";

            var first = true;

            var buildpackArray = Utilities.splitByCommas(buildpacks);

            for (var buildpackIndex = 0; buildpackIndex < buildpackArray.length; buildpackIndex++)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    result += "<br/>";
                }

                var buildpack = buildpackArray[buildpackIndex];

                if (type == "display")
                {
                    result += "<span title=\"" + Format.replaceScriptQuotes(buildpack) + "\">";

                    var sanitizedBuildpack = Format.removeScriptInjection(buildpack);
                    
                    if (sanitizedBuildpack.length > 20)
                    {
                        result += sanitizedBuildpack.substring(0, 20) + "...";
                    }
                    else
                    {
                        result += sanitizedBuildpack;
                    }

                    result += "</span>";
                }
                else
                {
                    result += buildpack;
                }
            }

            return result;
        }
        
        return buildpacks;
    },

    formatDate: function(dateString, showMillis)
    {
        if (dateString == null)
        {
            return "";
        }
        
        var dateObject = new Date(dateString);
              
        var date = "";
          
        var MONTHS = [
                         "Jan",
                         "Feb",
                         "Mar",
                         "Apr",
                         "May",
                         "Jun",
                         "Jul",
                         "Aug",
                         "Sep",
                         "Oct",
                         "Nov",
                         "Dec"
                     ];
          
        date += MONTHS[dateObject.getMonth()];
        date += " ";
        date += dateObject.getDate();
        date += ", ";
        date += dateObject.getFullYear();
        date += " ";    
        
        var hour = dateObject.getHours();
        var midday = "AM";
        if (hour > 11)
        { 
            midday = "PM";        
        }
        if (hour > 12)
        { 
            hour = hour - 12; 
        }
        if (hour == 0)
        { 
            hour = 12;        
        }
        date += hour;    
        date += ":";
        
        date += Utilities.padNumber(dateObject.getMinutes(), 2);
        date += ":";
        
        date += Utilities.padNumber(dateObject.getSeconds(), 2);
        
        if (showMillis == true)
        {
            var milliseconds = dateObject.getMilliseconds();
            if (milliseconds > 0)
            {
                date += ".";
                date += Utilities.padNumber(milliseconds, 3);
            }
        }

        date += " ";
        date += midday;
      
        return date;
    },

    formatDateNumber: function(dateString, showMillis)
    {
        if (dateString == null)
        {
            return "";
        }
        
        var timestamp = parseInt(dateString);

        return (isNaN(timestamp)) ? dateString : Format.formatDate(dateString, showMillis);
    },

    formatDateString: function(dateString)
    {
        if (dateString == null)
        {
            return "";
        }
        
        var timestamp = Date.parse(dateString);

        if (isNaN(timestamp) && (dateString.length > 0))
        {
            dateString = Format.fixDateString(dateString);

            timestamp = Date.parse(dateString);
        }

        return (isNaN(timestamp)) ? dateString : Format.formatDate(dateString);
    },

    formatDomainName: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 30);
    },
    
    formatGroups: function(groups, type)
    {
        if (groups == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "";

            var first = true;

            for (var groupIndex = 0; groupIndex < groups.length; groupIndex++)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    result += "<br/>";
                }

                var group = groups[groupIndex];

                if (type == "display")
                {
                    result += "<span title=\"" + Format.replaceScriptQuotes(group) + "\">";

                    var sanitizedGroup = Format.removeScriptInjection(group);
                    
                    if (sanitizedGroup.length > 30)
                    {
                        result += sanitizedGroup.substring(0, 30) + "...";
                    }
                    else
                    {
                        result += sanitizedGroup;
                    }

                    result += "</span>";
                }
                else
                {
                    result += group;
                }
            }

            return result;
        }
        
        return groups;
    },

    formatHostName: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 30);
    },
    
    formatIconImage: function(url)
    {
        if (url == null) 
        {
           return "";
        }
        
        var html = "<div  style='{2}'><img class='icon-image' src='{0}' alt='{1}'></div>";
        var altText = (arguments.length >= 2) ? arguments[1]: "";
        var style   = (arguments.length >= 3) ? arguments[2]: "";
        html = Utilities.localize(html, [url, altText, style]);
        return html;
    },

    formatNumber: function(value, type)
    {
        if (value == null)
        {
            if (type == "sort")
            {
                return -1;
            }
            
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            return (value.toString().indexOf(".") > 0) ? Utilities.addCommasToNumber(value.toFixed(1)) : Utilities.addCommasToNumber(value);
        }
        
        return value;
    },

    formatOrganizationName: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 20);
    },

    formatOrganizationStatus: function(status, type)
    {
        if (status == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "<span";

            if (status != "active")
            {
                result += " style='color: rgb(200, 0, 0);'";
            }

            result += ">" + status.toUpperCase();

            result += "</span>";

            return result;
        }
        
        return status.toUpperCase();
    },

    formatQuotaName: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 20);
    },
    
    formatServiceString: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 30);
    },

    formatSpaceName: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 20);
    },

    formatStacks: function(stacks, type)
    {
        if (stacks == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "";

            var first = true;

            for (var stackIndex in stacks)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    result += "<br/>";
                }

                var stack = stacks[stackIndex];

                if (type == "display")
                {
                    result += "<span title=\"" + Format.replaceScriptQuotes(stack) + "\">";

                    var sanitizedStack = Format.removeScriptInjection(stack);
                    
                    if (sanitizedStack.length > 14)
                    {
                        result += sanitizedStack.substring(0, 14) + "...";
                    }
                    else
                    {
                        result += sanitizedStack;
                    }

                    result += "</span>";
                }
                else
                {
                    result += stack;
                }
            }

            return result;
        }
        
        return stacks;
    },

    formatStatus: function(status, type, item)
    {
        if (status == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "<span";

            if ((status == Constants.STATUS__STOPPED) ||
                (status == Constants.STATUS__FAILED)  ||
                (status == Constants.STATUS__OFFLINE))
            {
                result += " style='color: rgb(200, 0, 0);'";
            }

            result += ">" + status;

            if (status == Constants.STATUS__OFFLINE)
            {
                result += " <img src='images/remove.png' onclick='AdminUI.removeItemConfirmation(\"" + item[item.length - 1] + "\")' class='removeButton' title='Remove " + item[item.length - 1] + "'/>";
            }

            result += "</span>";

            return result;
        }
        
        return status;
    },

    formatString: function(value)
    {
        return (value != null) ? value : "";
    },

    formatStringCleansed: function(value, type)
    {
        if (value == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            return Format.removeScriptInjection(value);
        }
        
        return value;
    },

    formatStringToolTip: function(value, type, length)
    {
        if (value == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "<span title=\"" + Format.replaceScriptQuotes(value) + "\">";

            var sanitizedValue = Format.removeScriptInjection(value);
            
            if (sanitizedValue.length > length)
            {
                result += sanitizedValue.substring(0, length) + "...";
            }
            else
            {
                result += sanitizedValue;
            }

            result += "</span>";
            
            return result;
        }
        
        return value;
    },

    formatTarget: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 30);
    },

    formatUptime: function(uptime)
    {
        if (uptime == null)
        {
            return "";
        }
        
        var result = "";

        var sections = uptime.split(":");

        if (sections.length == 4)
        {
            sections[0] = parseInt(sections[0].replace("d", ""));
            sections[1] = parseInt(sections[1].replace("h", ""));
            sections[2] = parseInt(sections[2].replace("m", ""));
            sections[3] = parseInt(sections[3].replace("s", ""));

            result = sections[0].toString();

            if (sections[0] == 1)
            {
                result += " day, ";
            }
            else
            {
                result += " days, ";
            }

            result += Utilities.padNumber(sections[1], 2) + ":";
            result += Utilities.padNumber(sections[2], 2) + ":";
            result += Utilities.padNumber(sections[3], 2);
        }

        return result;
    },

    formatURIs: function(uris, type)
    {
        if (uris == null)
        {
            return "";
        }
        
        if (Format.doFormatting(type))
        {
            var result = "";

            var first = true;

            for (var uriIndex in uris)
            {
                if (first)
                {
                    first = false;
                }
                else
                {
                    result += "<br/>";
                }

                var uri = "http://" + uris[uriIndex];

                if (type == "display")
                {
                    result += "<span title=\"" + Format.replaceScriptQuotes(uri) + "\">";

                    var sanitizedURI = Format.removeScriptInjection(uri);
                    
                    if (sanitizedURI.length > 40)
                    {
                        result += sanitizedURI.substring(0, 40) + "...";
                    }
                    else
                    {
                        result += sanitizedURI;
                    }

                    result += "</span>";
                }
                else
                {
                    result += uri;
                }
            }

            return result;
        }
        
        return uris;
    },
    
    formatUserString: function(name, type)
    {
        return Format.formatStringToolTip(name, type, 30);
    },
    
    removeScriptInjection: function(value)
    {
        return value.replace(/<\/?[^>]+(>|$)/g, "");
    },
    
    replaceScriptQuotes: function(value)
    {
        return value.replace(/"/g, "&quot;");
    }
};
