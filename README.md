[![Build Status](https://travis-ci.org/klappradla/im_graetzl.svg?branch=master)](https://travis-ci.org/klappradla/im_graetzl)
# imGrätzl

Ruby on Rails social network app Vienna.


## Getting Started

### Dependencies

* PostgreSQL with PostGIS extenstion for spatial data
* ImageMagick
* Ruby >= 2.1.0 (requrired by refile)
* GEOS and Proj for some spatial calculations


#### Test dependencies

* phantomjs


### Setup

general:

* `$ rake db:setup` to setup postgis DBs
* `$ rake db:seed` to import district and graetzl data

for local development:

* `$ rake db:populate` to populate DB with sample data


## Deployment

The app is hosted on [Amazon Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) (instance running Ruby 2.2.2, Puma, Nginx). Config in .ebextensions folder. Files are executed in alphabetical order:

* 01options.config
* 02packages.config - *install yum packages*
* 03nginx.conf - *Nginx conf to allow uploads up to 20MB*

