# New Main Contributor/Maintainer Needed
With the advent of the IBM announcement of IBM® Cloud Foundry being deprecated, this repository needs a new main contributor/maintainer. 
IBM announcement here: https://cloud.ibm.com/docs/cloud-foundry-public?topic=cloud-foundry-public-deprecation

# Administration Web UI for Cloud Foundry NG 

The Administration Web UI provides metrics and operations data for Cloud Foundry NG.
It gathers data from the varz providers and doppler_logging_endpoint for the various Cloud Foundry components as well as
from the Cloud Controller and UAA REST APIs.

See the [Using the Administration UI](#using) section for more information on using it and for sample screen shots.

## cf-release 245

In order to run the Administration UI on a release prior to cf-release v245, use the cf-release-pre-v245 branch.

CF releases for v245 and later continue to use the master branch.

This is due to the CCDB changes for applications in cf-release v245.

## Placement

In order to execute, the Administration UI needs to be able to access the following resources:

- NATS
- Cloud Controller REST API
- Cloud Controller DB URI
- UAA REST API
- UAA DB URI
- doppler logging endpoint

Installation of the Administration UI and its prerequisites requires access to the Internet to
access GitHub.com, RubyGems.org, Ubuntu software repositories, etc. 

## Installation Steps

### Ubuntu 18.04.5 64 bit

The last version of Ubuntu this has been tested upon is Ubuntu 18.04.5 64 bit.

### Ubuntu Prerequisite Libraries

```
# Update your package listing
sudo apt-get update

# Install prerequisite libraries
sudo apt-get install -f -y --no-install-recommends git-core build-essential libreadline-dev libssl-dev libsqlite3-dev openssl libpq-dev libmysqlclient-dev
```

### Ruby

Ruby is required to run the Administration UI. The last version used for development and testing is Ruby 3.1.2.

Here is a sample installation of ruby using rbenv:

```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
. ~/.profile
rbenv install 3.1.2
rbenv global 3.1.2
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

### Setup Administration UI group and user using uaac.

The following steps are the same if you are using the default bosh-lite install of Cloud Foundry or AWS install using [BOSH AWS Bootstrap](http://docs.cloudfoundry.org/deploying/ec2/bootstrap-aws-vpc.html).

```
# Target your bosh-lite UAA and get the 'admin' token
uaac target --skip-ssl-validation https://uaa.bosh-lite.com
uaac token client get admin -s admin-secret

# Add 'scim.write' if not already there and re-get token
uaac client update admin --authorities "`uaac client get admin | \
    awk '/:/{e=0}/authorities:/{e=1;if(e==1){$1="";print}}'` scim.write"
uaac token client get admin -s admin-secret

# Create a new group and add the 'admin' user to it
uaac group add admin_ui.admin
uaac member add admin_ui.admin admin

# Create the new UAA admin_ui_client
uaac client add admin_ui_client \
 --authorities clients.write,cloud_controller.admin,cloud_controller.read,cloud_controller.write,doppler.firehose,openid,scim.read,scim.write,sps.write,uaa.admin,uaa.resource \
 --authorized_grant_types authorization_code,client_credentials,refresh_token \
 --autoapprove true \
 --redirect_uri http://<admin ui host>:8070/login \
 --scope admin_ui.admin,admin_ui.user,openid \
 -s admin_ui_secret
```

**Note:** 
If you are using the default bosh-lite install, then running the above commands and setting the bosh-lite-specific configuration values in config/default.yml (`ccdb_uri` password, `cloud_controller_ssl_verify_none`, `mbus` password and `uaadb_uri` password) should enable you to use the default 
configuration values for the Administration UI and you can skip down to the
[Using the Administration UI](#using) section.
If you have installed Cloud Foundry on AWS using the AWS Bosh Bootstrap, then you will have to modify the Administration UI before moving forward.

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
Example: <code>0.0.0.0</code>
</dd>
<dt>
<code><b>ccdb_uri</b></code>
</dt>
<dd>
The URI used to connect to the Cloud Controller database for retrieval.
<br>
URI format: <code>&lt;protocol>://&lt;db-user>:&lt;db-user-password>@&lt;host>:&lt;port>/&lt;db-name></code>
<br>
Example: <code>postgres://ccadmin:admin@10.244.0.30:5524/ccdb</code>
<br>
Example: <code>mysql2://ccadmin:admin@10.244.0.30:3306/ccdb</code>
<br>
If you have MySQL database use <code>mysql2</code> protocol instead of <code>mysql</code>. Only PostgreSQL and MySQL have been tested to work with the Administration UI.
<br>
You can try other databases by adding relevant database gems to the <code>Gemfile</code> and executing <code>bundle update</code>. 
</dd>
<dt>
<code>cloud_controller_discovery_interval</code>
</dt>
<dd>
Seconds between cloud controller REST API discoveries.
<br>
Example: <code>300</code>
</dd>
<dt>
<code>cloud_controller_ssl_verify_none</code>
</dt>
<dd>
If connection to cloud_controller is https, true to ignore SSL verification.
<br>
Example: <code>true</code>
<br>
Example: <code>false</code>
</dd>
<dt>
<code><b>cloud_controller_uri</b></code>
</dt>
<dd>
The URI used to connect to the Cloud Controller REST API. This is also used as a title for the web UI header as well as email notification.
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
<code>cookie_key</code>
</dt>
<dd>
The key used for the session cookie.
<br>
Example: <code>mykey</code>
</dd>
<dt>
<code>cookie_secret</code>
</dt>
<dd>
The secret used for the session cookie.
<br>
Example: <code>mysecret</code>
</dd>
<dt>
<code>cookie_secure</code>
</dt>
<dd>
Whether the session cookie is secure or not.
<br>
Example: <code>true</code>
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
<code>db_uri</code>
</dt>
<dd>
The URI used to connect to a sqlite database instance.

If the database instance does not exist, Admin-UI will automatically create an instance. 
<br>
Example: <code>sqlite://data/store.db</code> 
<br>
In this case, the store.db file is located in the 'data' directory. Absolute path is allowed in the uri. For example,
<code>sqlite:///tmp/store.db</code> indicates the database file 'store.db' is located in the '/tmp' directory.
</dd>
<dt>
<code>display_encrypted_values</code>
</dt>
<dd>
Whether to display encrypted values like application environment variables, service instance credentials, service binding credentials, service key credentials, etc. 
Encrypted values are also only displayed if the signed-in user is a member of a UAA admin group for the Administration UI.
<br>
Example: <code>true</code>
<br>
Example: <code>false</code>
</dd>
<dt>
<code>doppler_data_file</code>
</dt>
<dd>
Relative path location to store the Administration UI doppler data file. 
<br>
Example: <code>data/doppler_data.json</code>
</dd>
<dt>
<code>doppler_logging_endpoint_override</code>
</dt>
<dd>
This optional URI is used to override the doppler_logging_endpoint retrieved from /v2/info. This can be used to offload filtering of the standard dopper_logging_endpoint to allow only those metrics consumed by the Administration UI, namely container metrics and value metrics. The doppler_logging_endpoint_override is required to support the same protocol as the base /v2/info doppler_logging_endpoint.
</dd>
<dt>
<code>doppler_reconnect_delay</code>
</dt>
<dd>
The number of seconds to wait until a reconnect to the doppler_logging_endpoint is attempted after a prior failure.
<br>
Example: <code>300</code>
</dd>
<dt>
<code>doppler_rollup_interval</code>
</dt>
<dd>
Seconds between rolling up doppler_logging_endpoint data to be made available. 
<br>
Example: <code>30</code>
</dd>
<dt>
<code>doppler_ssl_verify_none</code>
</dt>
<dd>
True to ignore SSL verification to doppler_logging_endpoint.
<br>
Example: <code>true</code>
<br>
Example: <code>false</code>
</dd>
<dt>
<code>event_days</code>
</dt>
<dd>
Maximum number of days of events in the past to include within the Events tab.
<br>
Example: <code>7</code>
</dd>
<dt>
<code>http_debug</code>
</dt>
<dd>
Whether http invocations will provide records in the log_file or not.
The default value is intentionally <code>false</code> as this is considered a security exposure.
Records within the log_file will be of log type <code>ANY</code>.
<br>
Example: <code>true</code>
<br>
Example: <code>false</code>
</dd>
<dt>
<code>log_file</code>
</dt>
<dd>
Relative path location to the Administration UI log file.
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
Log files in a comma-delimited array being exposed through the Administration UI. Note that these files must be accessible by the user that started the Administration UI. These files can either be found on a file system accessible by the local system or as an SFTP URI. In the case of SFTP, both
user:password and user with pem files are supported. If the SFTP password is not specified, the key files specified in log_file_sftp_keys will be used. <br>
Example <code>['/var/vcap/sys/log/cloud_controller_ng/cloud_controller_ng.log']</code>
<br>
Example <code>['/var/vcap/sys/log/cloud_controller_ng/*.log']</code>
<br>
Example <code>['/var/vcap/sys/log/**/*.log']</code>
<br>
Example <code>['sftp://someuser:somepassword@10.10.10.10/path/file.log']</code>
<br>
Example <code>['sftp://someuser@10.10.10.10/path/*.log']</code>
<br>
Example <code>['sftp://someuser:somepassword@10.10.10.10/path/**/*.log']</code>
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
<code>monitored_components</code>
</dt>
<dd>
Components in a comma-delimited array which when down will result in notification.
<br>
Example of multiple components: <code>[NATS, CloudController, DEA, HealthManager, Router]</code>
<br>
Example of a wild card:  <code>[-Provisioner]</code>
<br>
Example for all components:  <code>[ALL]</code>
</dd>
<dt>
<code>nats_discovery_interval</code>
</dt>
<dd>
Seconds between NATS discoveries.
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
<code>nats_tls</code>
</dt>
<dd>
A set of optional configuration properties for Admin-UI to securely communicate with NATS using TLS. These keys and values correspond to those documented for <a href="https://github.com/nats-io/nats.rb/blob/master/README.md#tls">TLS secure client connection within the NATS repository</a>.
<br>
<dl>
<dt>
<code>ca_file</code>
</dt>
<dd>
File path string referencing the NATS client certificate authority file. This is required if <code>verify_peer</code> has a value of <code>true</code>.
<br>
Example: <code>./ca.pem</code>
</dd>
<dt>
<code><b>cert_chain_file</b></code>
</dt>
<dd>
File path string referencing the NATS client certificate file.
<br>
Example: <code>./cert.pem</code>
</dd>
<dt>
<code><b>private_key_file</b></code>
</dt>
<dd>
File path string referencing the NATS client private key file.
<br>
Example: <code>./key.pem</code>
</dd>
<dt>
<code>verify_peer</code>
</dt>
<dd>
True to verify peer for the NATS client. If true, <code>ca_file</code> configuration is required.
<br>
Example: <code>true</code>
</dd>
</dl>
</dd>
<dt>
<code>port</code>
</dt>
<dd>
Port for the Administration UI web server. If the environment variable PORT is set, that value will be respected. This allows the Administration UI to run as a Cloud Foundry application.
<br>
Example: <code>8070</code>
</dd>
<dt>
<code>receiver_emails</code>
</dt>
<dd>
The receiving email(s) in a comma-delimited array.
<br>
Example: <code>[ ]</code>
<br>
Example: <code>[bar@10.10.10.10, baz@10.10.10.10]</code>
</dd>
<dt>
<code>secured_client_connection</code>
</dt>
<dd>
A true/false indicator about whether the Admin-UI server process will operate in secure or unprotected 
mode. In the secure mode, Admin-UI uses SSL security mechanism to protect communication with its users. 
As such, it requires its users to connect via https; in unprotected mode, Admin-UI expects http requests.
<br>
When set to 'true', a SSL certificate is required and the 'ssl' property must be present in the 
configuration file. Please see configuration property 'ssl' for details about how to configure Admin-UI 
to work with SSL certificate.<br>
By default, Admin-UI runs in the unprotected mode.
<br>
Example: <code>true</code>
</dd>
</dt>
<dt>
<code>sender_email</code>
</dt>
<dd>
Email server and account used when sending an email notifying receivers of down components.
<br>
<dl>
<dt>
<code><b>server</b></code>
</dt>
<dd>
The email server.
<br>
Example: <code>10.10.10.10</code>
</dd>
<dt>
<code>port</code>
</dt>
<dd>
Port of the email server.
<br>
Example: <code>25</code>
</dd>
<dt>
<code>domain</code>
</dt>
<dd>
HELO domain provided by the client to the server, the SMTP server will judge whether it should send or reject the SMTP session by inspecting the HELO domain.
<br>
Example: <code>localhost</code>
</dd>
<dt>
<code><b>account</b></code>
</dt>
<dd>
The email account.
<br>
Example: <code>system@10.10.10.10</code>
</dd>
<dt>
<code>secret</code>
</dt>
<dd>
Secret for the email account.
</dd>
<dt>
<code>authtype</code>
</dt>
<dd>
SMTP authentication scheme, can be one of: <code>plain</code>, <code>login</code>, <code>cram_md5</code>.
<br>
Example: <code>login</code>
</dd>
</dl>
</dd>
<dt>
<code>ssl</code>
</dt>
<dd>
A set of configuration properties for Admin-UI to work with SSL certificate. It 
is required when the 'secured_client_connection' is set to true.<br>
Certificate can be self-signed or signed by Certificate Authority (CA). Admin-UI 
supports these certificates. However, intermediate certificate from CA is not yet 
supported.<br>
<b>Generate Self-signed certificate</b><br>
You can generate a self-signed certificate on a server, all without involving 
third-party CA. The following steps illustrate a way in how you can generate a 
self-signed certificate:
* generate private key
<pre>
openssl genrsa -des3 -out /tmp/admin_ui_server.key -3 -passout pass:private_key_pass_phrase 2048
</pre>
This command creates a private key at 2048 bit length which is then encrypted with 
passphrase 'pass:private_key_pass_phrase' by way of DES3.
* Generate certificate request
<pre>
openssl req -new -key /tmp/admin_ui_server.key -out /tmp/admin_ui_server.csr -passin pass:private_key_pass_phrase
</pre>
This command yields a certificate request file by supplying the private key and 
passphrase involved in the previous step.
* Generate certificate
<pre>
openssl x509 -req -days 365 -passin pass:private_key_pass -in /tmp/admin_ui_server.csr -signkey /tmp/admin_ui_server.key -out /tmp/admin_ui_server.crt
</pre>
This command generates a certificate that is good for the next 365 days. At this 
point, you no longer need to keep the certificate request (dot csr file).
<br>
<dl>
<dt>
<code><b>certificate_file_path</b></code>
</dt>
<dd>
File path string referencing the certificate file.
<br>
Example: <code>certificate/server.cert</code>
</dd>
<dt>
<code><b>max_session_idle_length</b></code>
</dt>
<dd>
Time duration in seconds in which an https session is allowed to stay idle.
<br>
Example: <code>1800</code> for 30 minutes.
</dd>
<dt>
<code><b>private_key_file_path</b></code>
</dt>
<dd>
File path string referencing the private key file.
<br>
Example: <code>system@10.10.10.10</code>
</dd>
<dt>
<code><b>private_key_pass_phrase</b></code>
</dt>
<dd>
Password string that is used to encrypt the private key.
<br>
Example: <code>my_secret</code>
</dd>
</dl>
</dd>
<dt>
<code>stats_file</code>
</dt>
<dd>
Deprecated. Relative path location to store the Administration UI statistics. 

Admin-UI no longer stores its stats data in the stats file. Instead, the data is now stored in a database. This property 
is required only for the purpose of data migration. When data migration is no longer needed, you can remove this property 
from the configuration file. Please see the Data Migration section for details.
<br>
Example: <code>data/stats.json</code>
</dd>
<dt>
<code>stats_refresh_time</code>
</dt>
<dd>
Deprecated. See stats_refresh_schedules for details.
<br>
A daily schedule which starts at specified minutes from midnight for automatic stats collection
<br>
Example: <code>300</code>. This results in stats collection starting at 5 AM.
</dd>
<dt>
<code>stats_refresh_schedules</code>
</dt>
<dd>
Schedules of automatic stats collection expressed in an array of strings. Each string represents a schedule and follows a syntax very similar to crontab. It consists of five fields, for specifying time, date, days of a week and etc, as follow.
<br>
<pre>
       *        *        *        *        * 
       -        -        -        -        - 
       |        |        |        |        | 
       |        |        |        |        +----- day of week (0 - 6)(Sunday=0) 
       |        |        |        +------- month (1 - 12) 
       |        |        +--------- day of month (1 - 31)
       |        +----------- hour (0 - 23)
       +------------- minute (0 - 59)
       
       where * denotes an expression using legal values shown inside the parenthesis for the column. 
</pre>

* Fields are separated by spaces. 

* Fields can be expressed by a wild card * symbol which means every occurrence of the fields.
<br>
Example: <code>['0 * * * *']</code> means the collection starts once every hour at the beginning of the hour.

* Field value can be expressed in form of a range, which consists of two legal values connected by a hyphen (-).
<br>
Example: <code>['0 0 * * 1-5']</code> means the collection starts at midnight 12:00AM, Monday to Friday. 

* Field value can also be a sequence of legal values separated by comma. Sequence doesn't need to be monotonic.
<br>
Example: <code>['0 1,11,12,13 * * *']</code> means the collection process starts at 1:00AM, 11:00AM, 12:00PM and 1:00PM every day.

* Mixed uses of sequence and ranges are permitted. <br>
Example: The example above can expressed this way as well: <code>['0 1,11-13 * * *']</code>
<br>

* Step based repeat pattern like /4 is currently not supported.

* stats_refresh_schedules supports multiple schedules.
<br>
Example: <code>[ '0 1 * * *', '0 12-13 * * 1-5' ]</code> means the collection starts at 1:00AM everyday; on Monday to Friday, the collection process will also start at 12:00PM and 1:00PM.

This property supports the following predefined schedules
<br>
<pre>
<b>Predefined Schedule                        Description</b>
-----------------------------------------------------------------------------
 ['@hourly']                      runs at the beginning of every hour
 ['@daily']                       runs at the 12:00AM everyday
 ['@midnight']                    runs at the 12:00AM everyday
 ['@weekly']                      runs at the 12:00AM every Sunday
 ['@monthly']                     runs at the 12:00AM on first day of the month
 ['@yearly']                      runs at the 12:00AM on every Jan 1st
 ['@annually']                    runs at the 12:00AM on every Jan 1st. It is the same as @yearly.
</pre>

* When stats_refresh_schedules and stats_refresh_time are both present in the default.yml file, admin-ui will error out with an error message which reads 
Two mutually exclusive properties, stats_refresh_time and stats_refresh_schedules, are present in the configuration file. Please remove one of the two properties.<br>
* When neither stats_refresh_schedules supports nor stats_refresh_time is present in the default.yml file, admin-ui disables stats collection.<br>
* The default value of stats_refresh_schedules in default.yml file is <code>stats_refresh_schedules: ['0 5 * * *']</code>. This value translates to a schedule that starts daily at 5:00AM. <br>
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
<code>table_height</code>
</dt>
<dd>
Maximum height of the data table, will be set to 287px if not configured. If the records on the page are too large
to fit in this height then a vertical scroll bar will appear in the table. Can be set to either a specific pixel size
or a percentage. Using 100% will ensure that all data will be displayed without a scroll bar in the table.
<br>
Example: <code>100%</code>
</dd>
<dt>
<code>table_page_size</code>
</dt>
<dd>
Default selection for the page size in the table, will be set to 10 if not configured. Valid values are: 5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000.
<br>
Example: <code>25</code>
</dd>
<dt>
<code><b>uaa_client</b></code>
</dt>
<dd>
UAA client to access the Cloud Controller REST API as an admin user
and also support Single Sign On (SSO) for UI login.
<dl>
<dt>
<code><b>id</b></code>
</dt>
<dd>
Client ID.
<br>
Example: <code>admin_ui_client</code>
</dd>
<dt>
<code><b>secret</b></code>
</dt>
<dd>
Password for UAA client.
<br>
Example: <code>admin_ui_secret</code>
</dd>
</dl>
The UAA client used by the Administration UI must be added to the system via the cf-uaac command-line tool, BOSH deployment or equivalent and is required to consist of the following:
<ul>
<li>authorities: clients.write,cloud_controller.admin,cloud_controller.read,cloud_controller.write,doppler.firehose,openid,scim.read,scim.write,sps.write,uaa.admin,uaa.resource
<li>authorized_grant_types:  authorization_code,client_credentials,refresh_token
<li>autoapprove: true
<li>redirect_uri: http://&lt;admin ui host&gt;:8070/login 
<li>scopes: openid as well as those defined in the uaa_groups_admin and uaa_groups_user configuration values.
</ul>
Example: 
<pre>uaac client add admin_ui_client \
     --authorities clients.write,cloud_controller.admin,cloud_controller.read,cloud_controller.write,doppler.firehose,openid,scim.read,scim.write,sps.write,uaa.admin,uaa.resource \
     --authorized_grant_types authorization_code,client_credentials,refresh_token \
     --autoapprove true \
     --redirect_uri http://&lt;admin ui host&gt;:8070/login \
     --scope admin_ui.admin,admin_ui.user,openid \
     -s admin_ui_secret</code>
</pre>
</dd>
<dt>
<code><b>uaa_groups_admin</b></code>
</dt>
<dd>
UAA scope(s) in a comma-delimited array to identify qualifying scopes for admin access to the Administration UI.
If a user has any one scope, that user will be considered authorized to access the Administration UI as an admin.
<br>
Example: <code>[admin_ui.admin, cloud_controller.admin]</code>
<br>
The previously-unregistered groups referenced by this configuration property must be added to the system
via the cf-uaac CLI command or equivalent.
<br>
Example: <code>uaac group add admin_ui.admin</code>
<br>
The group membership then needs to be updated for each user that has admin capabilities
on the Administration UI.
<br>
Example: <code>uaac member add admin_ui.admin your_user_name</code>
</dd>
<dt>
<code><b>uaa_groups_user</b></code>
</dt>
<dd>
UAA scope(s) in a comma-delimited array to identify qualifying scopes for user access to the Administration UI.
If a user has any one scope, that user will be considered authorized to access the Administration UI as a user.
<br>
Example: <code>[admin_ui.user]</code>
<br>
The previously-unregistered groups referenced by this configuration property must be added to the system
via the cf-uaac CLI command or equivalent.
<br>
Example: <code>uaac group add admin_ui.user</code>
<br>
The group membership then needs to be updated for each user that has user capabilities
on the Administration UI.
<br>
Example: <code>uaac member add admin_ui.user your_user_name</code>
</dd>
<dt>
<code><b>uaadb_uri</b></code>
</dt>
<dd>
The URI used to connect to the UAA database for retrieval.
<br>
URI format: <code>&lt;protocol>://&lt;db-user>:&lt;db-user-password>@&lt;host>:&lt;port>/&lt;db-name></code>
<br>
Example: <code>postgres://uaaadmin:admin@10.244.0.30:5524/uaadb</code>
<br>
Example: <code>mysql2://uaaadmin:admin@10.244.0.30:3306/uaadb</code>
<br>
If you have MySQL database use <code>mysql2</code> protocol instead of <code>mysql</code>. Only PostgreSQL and MySQL have been tested to work with the Administration UI.
<br>
You can try other databases by adding relevant database gems to the <code>Gemfile</code> and executing <code>bundle update</code>. 
</dd>
<dt>
<code>varz_discovery_interval</code>
</dt>
<dd>
Seconds between VARZ discoveries.
<br>
Example: <code>30</code>
</dd>
</dl>

### Data Migration

Prior releases of Admin-UI store stats data in a file as indicated by the stats_file configuration property. This data is 
now stored in a database. Data migration is referring to the transfer of stats information from file to database.

Data migration takes place automatically at the start of admin-UI daemon process when the following conditions are all met:
  * stats_file property is present and valid in the default.yml file
  * db_uri property is present and valid in the default.yml file
  * stats file contains data
  * the database instance either does not exist or has not yet been initialized with schema.

When Admin-UI completes the data migration to database, it will rename the original stats file by appending '.bak' file 
extension. For example, 'stats.json' becomes 'stats.json.bak'. 

Data migration is run only once on a given database instance. If for some reason you wish to rerun data migration, you 
must operate on a different database instance.

### Database schema Migration 
At the start of its daemon process, Admin-UI always checks its database schema migration directory and attempts to bring its 
database schema up to date. So it's not required to run schema migration manually. This migration takes place before data 
migration.

The database schema migration directory is located at 'db/migrations'. This directory contains files responsible for both
populating database schema and subsequently migrating the schema. Migration files are built on the Sequel migration framework,
and hence adhere to its file naming convention. i.e. 

           <timestamp>_<title>.rb

The schema migration Admin-UI initiated always follows the chronological order as indicated by time stamps embedded in the 
migration file names.

More details about Sequel migration framework and ways to perform manual schema migration can be found  at the following URLs:

  * http://sequel.jeremyevans.net/rdoc/classes/Sequel/Migration.html
  * http://sequel.jeremyevans.net/rdoc/classes/Sequel/Migrator.html


## Execute Administration UI

You can provide an option to reference the configuration file when you execute the administration UI or you 
can let it default to config/default.yml

```
ruby bin/admin [-c <configuration file>]
```

## Simple Health Check

You can remotely check if the Administration UI is running by accessing the /health path and checking for a status code of 200. This path does not require authorization. Currently no response body is returned.

```
http://<admin ui host>:8070/health
```

## <a name="using"></a> Using the Administration UI 

To access the Administration UI, go to:

```
http://<admin ui host>:8070
```

You will be prompted for the credentials. Once there, by default, you will be
taken to the DEA tab:
![DEA Tab](./images/dea-tab.png)

From there you will see the list of DEAs running in the environment, along with
some basic statistics. Selecting one from the list will bring up another
table below the DEA table showing even more details about the DEA you selected:

![DEA Tab](./images/dea-tab-vm.png)

One important thing to note is that some of the items in the secondary
table are hyperlinks. Clicking on that link will take you to the appropriate
tab with a query already filled in, allowing you to see just the data
related to what you clicked on. For example, in the table above if you
clicked on the <code>Apps</code> link, meaning the <code>2</code>,
you'll be taken to the <code>Apps</code> tab and the query will be
filled in such that you will only see the apps running on this DEA,
as shown here:
![Apps Tab](./images/apps-tab.png)

Notice the <code>Search</code> entry field is pre-populated with a string
and the table is filtered to show just those rows that contain that string
in any column.

Also, note that each row in the table has a checkbox. While not all tables
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
contents in the text area. Use the buttons to iterate through the file
one page at a time, or use horizontal scroll bar at the top of the text area
to quickly move to one section of the file.

The <code>Stats</code> tab:

![Stats Tab](./images/stats-tab.png)

can be used to view basic history data about the environment. Normally, 
a snapshot of the statistics are taken once a day, but you can force a new
set of data points to be taken by using the <code>Create Stats</code>
button. 
