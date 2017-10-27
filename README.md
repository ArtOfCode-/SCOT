# CrowdRescue
Disaster response and relief management for volunteer teams

## Prerequisites
You'll need Ruby and MySQL installed to be able to set CrowdRescue up locally.

## Setup
 - Clone the repository and `cd` into the repository directory.
 - Install the required gems: `bundle install`
 - Copy sample config to real config (and fill in any missing values): `cp config/settings.sample.yml config/settings.yml`
 - Same for database config: copy and fill in your real username and password: `cp config/database.sample.yml config/database.yml`
 - Run MySQL (if it is not already running) with `mysqld`. Open a new console tab or window for the following commands. 
 - Set up the database: run `rails db:create`, `rails db:schema:load`,
   and `rails db:migrate`.
 - Run the server with `rails s`

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
