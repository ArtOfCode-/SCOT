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
 cp config/settings.sample.yml config/settings.yml
 ```
 - Same for database config: copy and fill in your real username and password:
 ```bash
 cp config/database.sample.yml config/database.yml
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
 rails s
 ```

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
