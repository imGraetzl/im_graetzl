[![Build Status](https://travis-ci.org/klappradla/im_graetzl.svg?branch=master)](https://travis-ci.org/klappradla/im_graetzl)
# imGrätzl

Ruby on Rails social network app Vienna.

### Table of Contents
1. [Getting Started](#getting-started)
3. [Deployment](#deployment)


## Getting Started

### Dependencies

* PostgreSQL with PostGIS extension for spatial data
* ImageMagick
* Ruby >= 2.1.0 (required by refile)
* GEOS and Proj for some spatial calculations


#### Test dependencies

* [PhantomJS](http://phantomjs.org/)


### Setup

Setup Postgis database and seed data (districts and graetzl):

    $ rake db:setup

Populate database with sample data:

    $ rake db:populate

## Deployment

The app is hosted on [Amazon Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) (instance running Ruby 2.2, Puma, Nginx). Config in .ebextensions folder. Files are executed in alphabetical order, e.g.:

* 01options.config
* 02packages.config - *install yum packages*
* 03nginx.conf
