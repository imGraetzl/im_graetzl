[![Build Status](https://travis-ci.org/klappradla/im_graetzl.svg?branch=master)](https://travis-ci.org/klappradla/im_graetzl)
[![Dependency Status](https://gemnasium.com/badges/github.com/imGraetzl/im_graetzl.svg)](https://gemnasium.com/github.com/imGraetzl/im_graetzl)

# imGrätzl

Ruby on Rails social network app Vienna.

### Table of Contents
1. [Getting Started](#getting-started)
3. [Deployment](#deployment)


## Getting Started

### Dependencies

* [PostgreSQL](http://www.postgresql.org/) 9.4 with [PostGIS](http://postgis.net/) extension for spatial data
* [ImageMagick](http://www.imagemagick.org/)
* Ruby >= 2.1.0 (required by refile)
* [GEOS](https://trac.osgeo.org/geos/) and [Proj](https://github.com/OSGeo/proj.4) for some spatial calculations

#### Test dependencies

* [PhantomJS](http://phantomjs.org/)

#### Setup on OSX

*Assuming you have a working ruby installation*  
Use [Homebrew](http://brew.sh/) to install the required dependencies:

```sh
$ brew install postgresql
# follow the install instructions
$ brew install postgis
# follow instructions to enable postgis extension
$ brew install geos proj phantomjs imagemagick
```

### Database Setup

Setup Postgis database and seed data (districts and graetzl):

    $ rake db:setup

Populate database with sample data:

    $ rake db:populate


## Deployment

The app is hosted on [Amazon Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) (instance running Ruby 2.2, Puma, Nginx). Config in .ebextensions folder. Files are executed in alphabetical order, e.g.:

* 01options.config
* 02packages.config - *install yum packages*
* 03nginx.conf
