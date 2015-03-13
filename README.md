[![Build Status](https://travis-ci.org/klappradla/im_graetzl.svg?branch=master)](https://travis-ci.org/klappradla/im_graetzl)
# imGrätzl

Prototype Ruby on Rails application for "imGrätzl" social network site Vienna. See a deployed version of the app [here](http://production-imgraetzl.rhcloud.com/) on [Openshift](https://www.openshift.com/).


## Getting Started

### Dependencies

The application uses:
* Ruby 2.0.0
* Ruby on Rails 4.1.4 (required version for OpenShift)
* PostgreSQL (in all environments)

The `.ruby-version` and `.ruby-gemset` specify the used Ruby and the name of the uses gemset ("meep") for rbenv, rvm and Travis CI.


## Deployment

The application uses Travis CI to automatically deploy the master branch to Openshift. See the `.travis.yml` file for the configuration of the process of continuous integration and the `.openshift` directory for configuring the build process on the OpenShift platform.

The app uses OpenShift's "hot deploy" maker to prevent shutdown and restart during build. To disable, remove the `hot_deploy` file in the `.openshift/markers` directory.