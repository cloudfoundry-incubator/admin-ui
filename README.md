[![Build Status](https://api.travis-ci.org/cloudfoundry-incubator/admin-ui.png)](https://travis-ci.org/cloudfoundry-incubator/admin-ui)
# Administration Web UI for Cloud Foundry NG 

The Administration Web UI provides metrics and operations data for Cloud Foundry NG.
It gathers data from the varz providers for the various Cloud Foundry components as well as
from the Cloud Controller and UAA REST APIs.

See the [Using the Administration UI](#using) section for more information on using it and for sample screen shots.

## Placement

In order to execute, the Administration UI needs to be able to access the following resources:

- NATS
- Cloud Controller REST API
- UAA REST API

Installation of the Administration UI and its prerequisites requires access to the Internet to
access GitHub.com, RubyGems.org, Ubuntu software repositories, etc. 

## Installation Steps

### Ubuntu 10.04.4 64 bit

This has been tested on Ubuntu 10.04.4 64 bit, Ubuntu 12.04.3 64 bit and Ubuntu 13.04 64 bit.

### Ubuntu Prerequisite Libraries

```
sudo apt-get install -f -y --no-install-recommends git-core build-essential libssl-dev
```

### Ruby

Ruby is required to run the Administration UI.  This has been tested with Ruby 1.9.3-p484.
Here is a sample installation of ruby using rbenv:

```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
. ~/.profile
rbenv install 1.9.3-p484
rbenv global 1.9.3-p484
```

### Ruby Bundler Gem
The bundler gem is required to install prerequisite gems for the Administration UI.

```
gem install bundler --no-rdoc --no-ri
```

If you are using rbenv you need to refresh the rbenv shims:

```
rbenv rehash
```

### Retrieve the Administration UI code

```
git clone https://github.com/cloudfoundry-incubator/admin-ui.git
```

### Install Administration UI

```
cd admin-ui
bundle install
```

### Administration UI Configuration 

Default configuration found in config/default.yml

Values that <b>must</b> be changed for your environment are marked in <b>bold</b>.

<dl>
<dt>
<code>bind_address</code>
</dt>
<dd>
The network address on which the server listens for web requests.
<br>
Example: <code>127.0.0.1</code>
</dd>
<dt>
<code>cloud_controller_discovery_interval</code>
</dt>
<dd>
Seconds between cloud controller REST API discoveries
<br>
Example: <code>300</code>
</dd>
<dt>
<code>cloud_controller_ssl_verify_none</code>
</dt>
<dd>
If connection to cloud_controller is https, true to ignore SSL verification
<br>
Example: <code>true</code>
<br>
Example: <code>false</code>
</dd>
<dt>
<code><b>cloud_controller_uri</b></code>
</dt>
<dd>
The URI used to connect to the Cloud Controller REST API.  This is also used as a title for the web UI header as well as email notification.
</dd>
<dt>
<code>component_connection_retries</code>
</dt>
<dd>
The number of times to try to talk to a varz component before considered failing.
<br>
Example: <code>2</code>
</dd>
<dt>
<code>data_file</code>
</dt>
<dd>
Relative path location to store the Administration UI data file.  
<br>
Example: <code>data/data.json</code>
</dd>
<dt>
<code>log_file</code>
</dt>
<dd>
Relative path locaton to the Administration UI log file
<br>
Example: <code>admin_ui.log</code>
</dd>
<dt>
<code>log_file_page_size</code>
</dt>
<dd>
Size of each log file page in bytes.
<br>
Example: <code>51200</code>
</dd>
<dt>
<code>log_file_sftp_keys</code>
</dt>
<dd>
Key files in a comma-delimited array to use to access logs using SFTP.
<br>
Example: <code>[/some_directory/some_key.pem]</code>
</dd>
<dt>
<code>log_files</code>
</dt>
<dd>
Log files in a comma-delimited array being exposed through the Administration UI. Note that these files must be accessible by the user that started the Administration UI.  These files can either be found on a file system accessible by the local system or as an SFTP URI.  In the case of SFTP, both
user:password and user with pem files are supported.  If the SFTP password is not specified, the key files specified in log_file_sftp_keys will be used. <br>
Example <code>[/var/vcap/sys/log/cloud_controller_ng/cloud_controller_ng.log]</code>
<br>
Example <code>[/var/vcap/sys/log/cloud_controller_ng/*.log]</code>
<br>
Example <code>[/var/vcap/sys/log/**/*.log]</code>
<br>
Example <code>[sftp://someuser:somepassword@10.10.10.10/path/file.log]</code>
<br>
Example <code>[sftp://someuser@10.10.10.10/path/*.log]</code>
<br>
Example <code>[sftp://someuser:somepassword@10.10.10.10/path/**/*.log]</code>
</dd>
<dt>
<code><b>mbus</b></code>
</dt>
<dd>
URL to the NATS.
<br>
Example: <code>nats://nats:c1oudc0w@10.10.10.10:4222</code>
</dd>
<dt>
<code>monitored_components<code>
</dt>
<dd>
Components in a comma-delimited array which when down will result in notification.
<br>
Example of multiple components: <code>[NATS, CloudController, DEA, HealthManager, Router]</code>
<br>
Example of a wildcard:  <code>[-Provisioner]</code>
<br>
Example for all components:  <code>[ALL]</code>
</dd>
<dt>
<code>nats_discovery_interval</code>
<dt>
<dd>
Seconds between NATS discoveries
<br>
Example: <code>30</code>
</dd>
<dt>
<code>nats_discovery_timeout</code>
</dt>
<dd>
The number of seconds to wait for the NATS to respond to <code>vcap.component.discover</code>.
<br>
Example: <code>10</code>
</dd>
<dt>
<code>port</code>
</dt>
<dd>
Port for the Administration UI web server.  
<br>
Example: <code>8070</code>
</dd>
<dt>
<code><b>receiver_emails</b></code>
</dt>
<dd>
The receiving email(s) in a comma-delimited array.
<br>
Example: <code>[ ]</code>
<br>
Example: <code>[bar@10.10.10.10, baz@10.10.10.10]</code>
</dd>
<dt>
<code><b>sender_email</b></code>
</dt>
<dd>
Email server and account used when sending an email notifying receivers of down components.
<br>
<dl>
<dt>
<code>server</code>
</dt>
<dd>
The email server.
<br>
Example: <code>10.10.10.10</code>
</dd>
<dt>
<code>account</code>
</dt>
<dd>
The email account.
<br>
Example: <code>system@10.10.10.10</code>
</dd>
</dl>
</dd>
<dt>
<code>stats_file</code>
</dt>
<dd>
Relative path location to store the Administration UI statistics.
<br>
Example: <code>data/stats.json</code>
</dd>
<dt>
<code>stats_refresh_time</code>
</dt>
<dd>
Deprecated.  See stats_refresh_schedules for details.
<br>
Daily minute from midnight for automatic stats collection
<br>
Example: <code>300</code>.  This results in stats collection at 5 AM.
</dd>
<dt>
<code>stats_refresh_schedules</code>
</dt>
<dd>
Schedules of automatic stats collection expressed in the form of an array of strings which follow syntax similar the crontab schedule.  Each string consists of five fields, for specifying time, date, days of a week and ect, as follows.
<br>
<br>
* &nbsp;&nbsp;&nbsp;* &nbsp;&nbsp;&nbsp;* &nbsp;&nbsp;&nbsp;* &nbsp;&nbsp;&nbsp;*  <br>
- &nbsp;&nbsp;&nbsp;- &nbsp;&nbsp;&nbsp;- &nbsp;&nbsp;&nbsp;- &nbsp;&nbsp;&nbsp;-  <br>
| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;<br>
| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;+----- day of week (0 - 6)(Sunday=0) <br>
| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;+------- month (1 - 12) <br>
| &nbsp;&nbsp;&nbsp;| &nbsp;&nbsp;&nbsp;+--------- day of month (1 - 31) <br>
| &nbsp;&nbsp;&nbsp;+----------- hour (0 - 23) <br>
+------------- minute (0 - 59) <br>
where * denotes an expression using legal values shown inside the parenthesis for the column. <br>

<br>
<br>
* Fields are separated by spaces.  
<br>
<br>
* Fields can be expressed by a wildcard * symbal which means every occurance of the fields.
<br><br>
For example, 
<br>
&nbsp;&nbsp;&nbsp;&nbsp;['0 * * * *'] means the collection starts once every hour at the beginning of the hour.
<br><br>
* Field value can be expressed in form of a range, which consists of two legal values connected by a hyphen (-).
<br><br>
For example,
<br>
&nbsp;&nbsp;&nbsp;&nbsp;['0 0 * * 1-5'] means the collection starts midnight 12:00AM, Monday to Friday.
<br><br>
* Field value can also be a sequence of legal values separated by comma.  Sequence doesn't need to be monitonic.
<br><br>
For example, 
<br>
&nbsp;&nbsp;&nbsp;&nbsp;['0 1,11,12,13 * * *'] means the collection process starts at 1:00AM, 11:00AM, 12:00PM and 1:00PM every day.
<br>
<br>
* Mixed uses of sequence and ranges are permitted. <br>
&nbsp;&nbsp;&nbsp;&nbsp;The example above can expressed this way as well: ['0 1,11-13 * * *']
<br>
<br>
* Step based repeat pattern like /4 is currently not supported.
<br>
<br>
<b>Reference: </b>[Please see crontab syntax (http://www.adminschoice.com/crontab-quick-reference/) for details](http://www.adminschoice.com/crontab-quick-reference/) 
<br>
<br>
* stats_refresh_schedules supports multiple schedules.
<br>
<br>
For example, 
<br>
&nbsp;&nbsp;&nbsp;&nbsp;[ '0 1 * * *', '0 12-13 * * 1-5' ] means the collection starts at 1:00AM everyday; on Monday to Friday, the collection process will also start at 12:00PM and 1:00PM.
<br>
<br>
This property supports the following predefined schedules
<br>
<br>
Predefined Schedule &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Description                                  <br>
----------------------------------------------------------------------------
<br>
&nbsp;&nbsp; ['@hourly'] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; runs at the beginning of every hour
<br>
&nbsp;&nbsp; ['@daily'] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  runs at the 12:00AM everyday
<br>
&nbsp;&nbsp; ['@weekly'] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  runs at the 12:00AM every Sunday
<br>
&nbsp;&nbsp; ['@monthly'] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  runs at the 12:00AM on first day of the month
<br>
&nbsp;&nbsp; ['@yeary'] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  runs at the 12:00AM on every Jan 1st
<br>
&nbsp;&nbsp; ['@annually'] &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  runs at the 12:00AM on every Jan 1st.  It is the same as @yearly.
<br>
<br>
* When stats_refresh_schedules supports and stats_refresh_time are both present in the default.yml file, stats_refresh_time setting is ignored and ony stats_refresh_schedules supports setting is taken.
<br>
</dd>
<dt>
<code>stats_retries</code>
</dt>
<dd>
Number of stats retries.
<br>
Example: <code>5</code>
</dd>
<dt>
<code>stats_retry_interval</code>
</dt>
<dd>
Seconds between stats collection saving.
<br>
Example: <code>300</code>
</dd>
<dt>
<code><b>uaa_admin_credentials</b></code>
</dt>
<dd>
UAA credentials to access the Cloud Controller REST API as an admin user
<br>
<dl>
<dt>
<code>username</code>
<dt>
<dd>
User for UAA login.
<br>
Example: <code>admin</code>
</dd>
<dt>
<code>password</code>
</dt>
<dd>
Password for UAA login.
<br>
Example: <code>c1oudc0w</code>
</dd>
</dl>
</dd>
<dt>
<code><b>ui_credentials</b></code>
</dt>
<dd>
Credentials to access the Administration UI as a standard user.
<br>
<dl>
<dt>
<code>username</code>
</dt>
<dd>
User for standard login.
<br>
Example: <code>user</code>
</dd>
<dt>
<code>password</code>
</dt>
<dd>
Password for standard login.
<br>
Example: <code>passw0rd</code>
</dd>
</dl>
<dt>
<code><b>ui_admin_credentials</b></code>
</dt>
<dd>
Credentials to access the Administration UI as an admin user
<br>
<dl>
<dt>
<code>username</code>
<dt>
<dd>
User for admin login.
<br>
Example: <code>admin</code>
</dd>
<dt>
<code>password</code>
</dt>
<dd>
Password for admin login.
<br>
Example: <code>passw0rd</code>
</dd>
</dl>
</dd>
<dt>
<code>varz_discovery_interval</code>
<dt>
<dd>
Seconds between VARZ discoveries
<br>
Example: <code>30</code>
</dd>
</dl>

## Execute Administration UI

You can provide an option to reference the configuration file when you execute the administration ui or you 
can let it default to config/default.yml

```	
ruby bin/admin [-c <configuration file>]
```

## <a name="using"></a> Using the Administration UI 

To access the Administration UI, go to:

```
http://<admin ui host>:8070
```

You will be prompted for the credentials.  Once there, by default, you will be
taken to the DEA tab:
![DEA Tab](./images/dea-tab.png)

From there you will see the list of DEAs running in the environment, along with
some basic statistics.  Selecting one from the list will bring up another
table below the DEA table showing even more details about the DEA you selected:

![DEA Tab](./images/dea-tab-vm.png)

One important thing to note is that some of the items in the secondary
table are hyperlinks. Clicking on that link will take you to the appropriate
tab with a query already filled in, allowing you to see just the data
related to what you clicked on.  For example, in the table above if you
clicked on the <code>Apps</code> link, meaning the <code>2</code>,
you'll be taken to the <code>Apps</code> tab and the query will be
filled in such that you will only see the apps running on this DEA,
as shown here:
![Apps Tab](./images/apps-tab.png)

Notice the <code>Search</code> entry field is pre-populated with a string
and the table is filtered to show just those rows that contain that string
in any column.

Also, note that each row in the table has a checkbox.  While not all tables
will have those, by selecting a set of rows an action can be performed on
them. For example, in this case, by selecting one or more apps you can then
use the buttons on the right side of the main table:

![Apps Buttons](./images/apps-buttons.png)

to start, stop, restart, etc. those apps.

All of the tabs will follow the same interaction pattern as described above.

There are however a few other tabs that worth calling out.

The <code>Logs</code> tab will display the contents of the log files that the
Administration UI has access to - these need to be local to the application:

![Logs Tab](./images/logs-tab.png)

On this tab, once a particular log file is selected, you can examine its
contents in the text area.  Use the buttons to iterate through the file
one page at a time, or use horizontal scroll bar at the top of the text area
to quickly move to one section of the file.

The <code>Stats</code> tab:

![Stats Tab](./images/stats-tab.png)

can be used to view basic history data about the environment.  Normally, 
a snapshot of the statitics are taken once a day, but you can force a new
set of data points to be taken by using the <code>Create Stats</code>
button. 
