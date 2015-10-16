[![Build Status](https://travis-ci.org/klappradla/im_graetzl.svg?branch=master)](https://travis-ci.org/klappradla/im_graetzl)
# imGrätzl

Ruby on Rails social network app Vienna.

### Table of Contents
1. [Getting Started](#getting-started)
2. [Development with Vagrant](#development-with-vagrant)
3. [Development Notes](#development-notes)
3. [Deployment](#deployment)


## Getting Started

### Dependencies

* PostgreSQL with PostGIS extenstion for spatial data
* ImageMagick
* Ruby >= 2.1.0 (requrired by refile)
* GEOS and Proj for some spatial calculations


#### Test dependencies

* [PhantomJS](http://phantomjs.org/)


### Setup

general:

* `$ rake db:setup` to setup postgis DBs
* `$ rake db:seed` to import district and graetzl data

for local development:

* `$ rake db:populate` to populate DB with sample data


## Development with Vagrant

### Set up Vagrant

Set up Vagrant on your local machine:

1. Download and install [Vagrant](http://www.vagrantup.com/downloads.html)
2. Download and install [Virtual Box](https://www.virtualbox.org/wiki/Downloads)


Install required plugins for Vagrant in Terminal: *(might take a while)*

```
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-librarian-chef-nochef
```

We use Vagrant's option to [sync folders with RSync](https://docs.vagrantup.com/v2/synced-folders/rsync.html) (to avoid permission issues on Windows machines).

Check if [RSync](https://rsync.samba.org/) is already installed (should be avilable on Unix systems).

```
rsync --version
```
On Windows, if not available, there are several options:

1. Get package with Cygwin ([follow these steps](http://terokarvinen.com/rsync_from_windows.html#install_cygwin_with_rsync))
2. Install [MYSYS2](http://sourceforge.net/projects/msys2/) (minimal version of Cygwin coming with Pacman package manager 👍) and follow these steps:

  ```
  # update package repository (just in case)
  pacman -Sy
  
  # install rsync
  pacman -S rsync
  
  # check again (should now be available)
  rsync --version
  ```


### Start Vagrant

Fire up a terminal window within the project's root directory.
If present, remove the '.ruby-version' file in this directory.

```
rm .ruby-version
```

Next, run vagrant up to initalize and start the virtual machine.

```
vagrant up
```

Running `vagrant up` for the first time might take some time. It will setup an Ubuntu Box running Ruby 2.2.1 and PostgreSQL 9.4 with PostGIS extension enabled. It initalizes the rails app, loads the seed data (graetzls and districts) into the database and populates the database with example data for development.


### Start the app

Having Vagrant up, SSH into your Vagrant instance and change into the application directory and start a rails server on the local port 3000

```
vagrant ssh
cd /vagrant
rails s -b 0.0.0.0
```

The app in now available on your local machine's port 3000: **http://localhost:3000** (first time starting the app takes a while).

#### Sample data

The populate task adds 4 admin users: *malano, mirjam, jack, peter, jeanine, max, tawan* and a busines user *user_1* with password *secret*.

#### Managing gems

The box setup uses [rbenv](https://github.com/sstephenson/rbenv) to manage rubies and gems. To install gems / update accoding to changes in Gemfile:

```
# ssh into the box
vagrant ssh
cd /vagrant

# run bundle command and rehash
bundle install
rbenv rehash
```


### Stop the app
Stop the rails server with `ctrl c`, exit the SSH session and suspend your Vagrant box.

```
exit
vagrant suspend
```

Next time running `vagrant up`, the database will be in the same state you left it.

## Development Notes

### Activity Feed (avoid N+1 queries)

The activity feed uses chaps-io's [public activity](https://github.com/chaps-io/public_activity) gem. In order to be able to eager load different associations for the polymorphic 'trackable' association, the models must be added as an additional 'belongs_to' association to the 'PublicActivity::Activity' model. The definition goes into:

`config/initializers/public_activity.rb`

Afterwards, different associations can be eager loaded using `.includes`:

```ruby
PublicActivity::Activity.includes(post: [:user, :images], meeting: [:address])
```


### Server
The app in runing [puma](https://github.com/puma/puma) in all environments.

## Deployment

The app is hosted on [Amazon Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/) (instance running Ruby 2.2.2, Puma, Nginx). Config in .ebextensions folder. Files are executed in alphabetical order:

* 01options.config
* 02packages.config - *install yum packages*
* 03nginx.conf - *Nginx conf to allow uploads up to 20MB*

