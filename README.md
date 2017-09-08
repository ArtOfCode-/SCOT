# CrowdRescue
Disaster response and relief management for volunteer teams

## Prerequisites
You'll need Ruby and MySQL installed to be able to set CrowdRescue up locally.

## Setup
 - Clone the repository and `cd` into the repository directory.
 - Install the required gems: `bundle install`
 - Copy sample config to real config (and fill in any missing values): `cp config/settings.sample.yml config/settings.yml`
 - Set up the database: create and fill in `config/database.yml`, then run `rails db:create`, `rails db:schema:load`,
   and `rails db:migrate`.
 - Run the server with `rails s`
