[![Build Status](https://travis-ci.org/imGraetzl/im_graetzl.svg?branch=master)](https://travis-ci.org/imGraetzl/im_graetzl)
[![Dependency Status](https://gemnasium.com/badges/github.com/imGraetzl/im_graetzl.svg)](https://gemnasium.com/github.com/imGraetzl/im_graetzl)

# imGrätzl

Geo-data backed Ruby on Rails social network app Vienna.

### Table of Contents
1. [Getting Started](#getting-started)
1. [Development](#development)
3. [Deployment](#deployment)


## Getting Started

### Dependencies

* [PostgreSQL](http://www.postgresql.org/) 9.4 with [PostGIS](http://postgis.net/) extension for spatial data
* [ImageMagick](http://www.imagemagick.org/)
* Ruby >= 2.3.0 *is what we run in production*
* [GEOS](https://trac.osgeo.org/geos/) and [Proj](https://github.com/OSGeo/proj.4) for some spatial calculations

### Test dependencies

* [PhantomJS](http://phantomjs.org/) for a headless browser

## Development

### Setup on OSX

*Assuming you have a working ruby installation*  
Use [Homebrew](http://brew.sh/) to install the required dependencies:

```sh
$ brew install postgresql
# follow the install instructions
$ brew install postgis
# follow instructions to enable postgis extension
$ brew install geos proj phantomjs imagemagick
```

### Setup with Vagrant

#### Prerequisites

1. Install the latest version of [VirtualBox](https://www.virtualbox.org/) for your OS
2. Install the latest version of [Vagrant](https://www.vagrantup.com/) for your OS

#### Setup VM

In the project directory, run:

    $ vagrant up

This will spin up a new VM and install all required dependencies.

Once the VM is ready, in the project directory run:

```shell
$ vagrant ssh   # to ssh into your VM
$ cd /vagrant   # to change into the mounted project directory within the VM
```

Once you are there and it is your first time spinning up the VM, set up and eventually populate the database as described in [Database Setup](#database-setup).

#### Run the application

To run the server:

```sh
$ rails server -b 0.0.0.0   # this makes the application available on http://localhost:3000
```
Use `CTRL` + `c` to shut down the server again.

#### Run the tests

To run the tests:

    $ rspec spec

#### Shut down VM

To exit your ssh session in the VM, simply run:

    $ exit

To shut down the VM, run:

```sh
$ vagrant halt   # $ vagrant up will continue at the state you left the VM
```

### Database Setup

Setup Postgis database and seed data (districts and graetzl):

    $ rake db:setup

Populate database with sample data:

    $ rake db:populate


## Deployment

The app is hosted on [Amazon Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) (single instance type running Ruby 2.3, Puma, Nginx). Config in .ebextensions folder. Files are executed in alphabetical order:

* 01options.config         - *Set Rails specific Elastic Beanstalk variables*
* 02packages.config        - *Install yum packages*
* 03nginx.config           - *Configure webserver*
* 04cron.config            - *Load automated tasks in crontab*
* 05eb_housekeeping.config - *Remove old application versions*
* 06permissions.config     - *Set file permissions*
* 07sitemap.config         - *Refresh sitemap*

See the [wiki](https://github.com/imGraetzl/im_graetzl/wiki) for further instructions and tutorials.
