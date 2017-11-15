# CrowdRescue
Disaster response and relief management for volunteer teams

## Prerequisites
You'll need Ruby and MySQL installed to be able to set CrowdRescue up locally.

## Setup
 - Clone the repository and `cd` into the repository directory.
 - Install the required gems:
 ```bash
 $ bundle install
 ```
 - Copy sample config to real config, and fill in any missing values. You'll need to [set up a Google Maps API token](https://developers.google.com/maps/documentation/javascript/get-api-key) to insert in the config file.
 ```bash
$ cp config/settings.sample.yml config/settings.yml
 ```
 - Same for database config: copy and fill in your real username and password:
 ```bash
$ cp config/database.sample.yml config/database.yml
 ```
 - Run MySQL if it is not already running.

You can check if MySQL is running with

```bash
$ ps aux | grep mysql
```

On Linux, start MySQL with

```bash
$ sudo systemctl restart mysql
```

On Mac, use

```bash
$ mysqld
```

 - Set up the database:

```bash
$ rails db:create
$ rails db:schema:load
$ rails db:migrate
```

 - Run the server with
 ```bash
 $ rails s
 ```

## MySQL permissions setup

You may see an error about MySQL permissions. If you do, you need to set up your user's permissions within MySQL.

You'll want to log in to MySQL as `root` so you can make these changes. Make sure MySQL is running first. On MacOS, run:

```bash
$ sudo mysql
```

Enter your password (the one you normally use with `sudo`, not a MySQL related password). 

On Linux, use:

```bash
$ mysql -u root -p
```

You'll now be in the MySQL console.

Change to the system database for MySQL.

```sql
mysql> use mysql;
```

List the MySQL users.

```sql
mysql> select user from user;
+---------------+
| user          |
+---------------+
| <your name>   |
| mysql.session |
| mysql.sys     |
| root          |
+---------------+
```

`<your name>` should be there; this should be the same name as the `username` listed in `config/database.yml`.

Look at the grants given to your user.

```sql
mysql> show grants for <your name>@localhost;
```

If you're having permission errors you probably do not have the needed grants.

Grant yourself all privileges on all tables on `crowdrescue_dev`. This will have been created when you ran the rails setup commands listed above.

```sql
mysql> GRANT ALL PRIVILEGES ON `crowdrescue_dev`.* TO '<your name>'@'localhost';
```

If you have other databases set up locally, like `crowdrescue_test` or `crowdrescue_prod`, grant yourself permission on those as well.

```sql
mysql> GRANT ALL PRIVILEGES ON `crowdrescue_test`.* TO '<your name>'@'localhost';
mysql> GRANT ALL PRIVILEGES ON `crowdrescue_prod`.* TO '<your name>'@'localhost';

```

Then tell MySQL to apply these changes with

Now make sure the privileges got added properly:

```sql
mysql> show grants for <your name>@localhost;
+--------------------------------------------------------------------------------------+
| Grants for <your name>@localhost                                                           |
+--------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON `crowdrescue_dev`.* TO '<your name>'@'localhost' WITH GRANT OPTION |
| GRANT ALL PRIVILEGES ON `crowdrescue_test`.* TO '<your name>'@'localhost'                  |
+--------------------------------------------------------------------------------------+
```

You can now leave the MySQL console.

```sql
mysql> exit
Bye
```

Now try running SCOT again, you should have the permissions you need.

## License
    SCOT - disaster response/relief management for volunteer teams
    Copyright (c) 2017 Owen Jenkins and contributors

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
