# IBM Administration Web UI for CloudFoundry NG

The IBM Administration Web UI provides metrics and operations data for CloudFoundry NG.
It gathers data from the varz providers for the various CloudFoundry components as well as
from the cloud controller and uaa databases.

## Placement

In order to exeucute, the administration ui needs to be able to access the following resources:

- NATS
- Cloud controller database
- UAA database

Installation of the administration ui and its prerequisites require access to the internet to
access github.com, rubygems.org, ubuntu software repositories, etc. 

## Installation Steps

### Ubuntu 10.04.4 64 bit

This has been tested on Ubuntu 10.04.4 64 bit, Ubuntu 12.04.3 64 bit and Ubuntu 13.04 64 bit.

### Ubuntu Prerequisite Libraries

```
sudo apt-get install -f -y --no-install-recommends git-core build-essential libpq-dev
```

### Ruby

Ruby is required to run the administration ui.  This has been tested with Ruby 1.9.3-p448.
Here is a sample installation of ruby using rbenv:

```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
. ~/.profile
rbenv install 1.9.3-p448
rbenv global 1.9.3-p448
```

### Ruby Bundler Gem
The bundler gem is required to install prerequisite gems for the administration ui.

```
gem install bundler --no-rdoc --no-ri
```

If you are using rbenv you need to refresh the rbenv shims:

```
rbenv rehash
```

### Retrieve the administration ui code

```
git clone https://github.com/cloudfoundry/ibm-admin-ui.git
```

### Install Administration UI

```
cd ibm-admin-ui
bundle install
```

### Administraton UI Configuration 

Default configuration found in config/default.yml

Values that <b>must</b> be changed for your environment are marked in <b>bold</b>.

<dl>
<dt>
<code><b>cloud_controller_uri</b></code>
</dt>
<dd>
Title used for web ui header as well as email notification.
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
<code><b>cc</b></code>
</dt>
<dd>
URL to the cloud controller database.
<br>  
Example: <code>postgres://ccadmin:c1oudc0w@10.10.10.10:5524/ccdb</code>
</dd>
<dt>
<code><b>uaa</b></code>
</dt>
<dd>
URL to the UAA database.
<br>
Example: <code>postgres://uaaadmin:c1oudc0w@10.10.10.10:5524/uaadb<code>
</dd>
<dt>
<code>port</code>
</dt>
<dd>
Port for the administration ui web server.  
<br>
Example: <code>8070</code>
</dd>
<dt>
<code>data_file</code>
</dt>
<dd>
Relative path location to store the administration ui data file.  
<br>
Example: <code>data/data.json</code>
</dd>
<dt>
<code>stats_file</code>
</dt>
<dd>
Relative path location to store the administration ui statistics.
<br>
Example: <code>data/stats.json</code>
</dd>
<dt>
<code>log_file</code>
</dt>
<dd>
Relative path locaton to the administration ui log file
<br>
Example: <code>admin_ui.log</code>
</dd>
<dt>
<code><b>ui_credentials</b></code>
</dt>
<dd>
Credentials to access the administration ui as a standard user.
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
Credentials to access the administration ui as an admin user
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
<code>dea_retries</code>
<dt>
<dd>
Number of attempts to talk to the DEA's varz endpoint.  In v1, the DEA would often responde with varz content which did not include app information.
<br>
Example: <code>10</code>
</dd>
<dt>
<code>nats_discovery_timeout</code>
</dt>
<dd>
The amount of seconds to wait for the NATS to respond to <code>vcap.component.discover</code>.
<br>
Example: <code>10</code>
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
<code>monitored_components<code>
</dt>
<dd>
Array of components which when down will result in notification.
<br>
Example: <code>- NATS</code>
<br>
Example: <code>- CloudController</code>
<br>
Example: <code>- DEA</code>
<br>
Example: <code>- HealthManager</code>
<br>
Example: <code>- Router</code>
<br>
Example of a wildcard:  <code>- -Provisioner</code>
<br>
Example for all components:  <code>- ALL</code>
</dd>
<dt>
<code>cache_refresh_interval</code>
<dt>
<dd>
Seconds between NATS discoveries
<br>
Example: <code>30</code>
</dd>
<dt>
<code>stats_refresh_time</code>
</dt>
<dd>
Daily minute for automatic stats collection
<br>
Example: <code>300</code>.  This results in stats collection at 5 AM.
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
<code>stats_retries</code>
</dt>
<dd>
Number of stats retries.
<br>
Example: <code>5</code>
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
<code>log_files</code>
</dt>
<dd>
Array of log files being exposed through the administration ui. Note that these files must be accessible by the user that started the administration ui.
<br>
Example <code>- /var/vcap/sys/log/cloud_controller_ng/*.log</code>
</dd>
</dl>

## Execute Administration UI

You can provide an option to reference the configuration file when you execute the administration ui or you 
can let it default to config/default.yml

```	
ruby bin/admin [-c <configuration file>]
```

## View Administration UI 

```
http://<admin ui host>:8070
```
