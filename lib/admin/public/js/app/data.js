
var Data =
{
    URLs: [
              Constants.URL__APPLICATIONS, 
              Constants.URL__CLOUD_CONTROLLERS,
              Constants.URL__COMPONENTS,
              Constants.URL__DEAS,
              Constants.URL__GATEWAYS,
              Constants.URL__HEALTH_MANAGERS,
              Constants.URL__LOGS,
              Constants.URL__ORGANIZATIONS,
              Constants.URL__ROUTERS,
              Constants.URL__ROUTES,
              Constants.URL__SERVICES,
              Constants.URL__SERVICE_BINDINGS,
              Constants.URL__SERVICE_INSTANCES,
              Constants.URL__SERVICE_PLANS,
              Constants.URL__SPACES,
              Constants.URL__SPACES_DEVELOPERS,
              Constants.URL__STATS,
              Constants.URL__TASKS,
              Constants.URL__USERS
          ],

    cache: [],


    initialize: function()
    {
        $(this.URLs).each($.proxy(function(index, url) { this.cache[url] = {}; }, this));
    },

    get: function(uri, reload)
    {
        var promise = null;

        if (this.cache[uri].retrieving)
        {
            promise = this.cache[uri].deferred.promise();
        }
        else if (reload)
        {
            this.cache[uri].retrieving = true;

            this.cache[uri].response = null;
            this.cache[uri].error    = null;

            this.cache[uri].deferred = new $.Deferred();

            var ajaxDeferred = $.ajax({
                                          url: "/" + uri,
                                          dataType: "json"
                                      });

            ajaxDeferred.done($.proxy(function(response, status)
            {
                this.cache[uri].response = response;
            },
            this));

            ajaxDeferred.fail($.proxy(function(xhr, status, error)
            {
                if (xhr.status == 303)
                {
                    window.location.href = "login.html";
                }
                else
                {
                    this.cache[uri].error = error;
                }
            },
            this));

            ajaxDeferred.always($.proxy(function(xhr, status, error)
            {
                this.cache[uri].retrieving = false;

                this.cache[uri].deferred.resolve(this.cache[uri]);
            },
            this));

            promise = this.cache[uri].deferred.promise();
        }
        else
        {
            promise = new $.Deferred().resolve(this.cache[uri]);
        }

        return promise;
    },

    refresh: function()
    {        
        var deferreds = [];

        $(this.URLs).each($.proxy(function(index, url) { deferreds.push(this.get(url, true)); }, this));

        $.when.apply(this, deferreds).done(function()
        {
            var connected = true;

            for (index in arguments)
            {
                if ((arguments[index].response.connected != null) && (!arguments[index].response.connected))
                {
                    connected = false;
                    break;
                }
            }

            if (connected)
            {
                $(".disconnected").hide();
            }
            else
            {
                $(".disconnected").show();
            }
        });
    }
}

