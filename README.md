Description
-----------

[![Build Status](https://travis-ci.org/projecthydra/active_fedora.png?branch=master)](https://travis-ci.org/projecthydra/active\_fedora)
[![Version](https://badge.fury.io/rb/active-fedora.png)](http://badge.fury.io/rb/active-fedora)
[![Dependencies](https://gemnasium.com/projecthydra/active_fedora.png)](https://gemnasium.com/projecthydra/active\_fedora)
[![Coverage Status](https://img.shields.io/coveralls/projecthydra/active_fedora.svg)](https://coveralls.io/r/projecthydra/active_fedora)

Rubydora and ActiveFedora provide a set of Ruby gems for creating and
managing objects in the Fedora Repository Architecture
([http://fedora-commons.org](http://fedora-commons.org)). ActiveFedora
is loosely based on “ActiveRecord” in Rails. The 3.x series of
ActiveFedora depends on Rails 3, specifically activemodel and
activesupport.

Getting Help
------------

-   Community Discussions & Mailing List are located at
    [http://groups.google.com/group/hydra-tech](http://groups.google.com/group/hydra-tech)
-   Developers hang out on IRC in \#projecthydra on freenet.

Installation
------------

The gem is hosted on rubygems.

    gem install active-fedora

Getting Started
---------------

The [Dive into Hydra](https://github.com/projecthydra/hydra/wiki/Dive-into-Hydra)
gives you a brief tour through ActiveFedora’s features on the command
line.

Generators
----------

You can generate a model inheriting from ActiveFedora::Base.

    rails generate active_fedora:model Book

Testing (this Gem)
------------------

In order to run the RSpec tests, you need to have a copy of the
ActiveFedora source code, and then run bundle install in the source
directory. Testing requires hydra-jetty, which contains version for
Fedora and Solr. Setting up and maintaining hydra-jetty for the purposes
of testing this gem is all accomplished via

    git clone https://github.com/projecthydra/active_fedora.git
    cd /wherever/active_fedora/is
    bundle install

### Using the continuous integration server

You can test ActiveFedora using the same process as our continuous
integration server. To do that, unzip a copy\
of hydra-jetty first. This includes copies of Fedora and Solr which are
used during the testing process.

      rake jetty:unzip 

Once hydra-jetty is unzipped, the ci rake task will spin up jetty,
import the fixtures, and run the tests for you.

      rake active_fedora:ci

### Testing Manually

If you want to run the tests manually, follow these instructions.

You need to have a copy of hydra-jetty running. To do this, download a
working copy of
[hydra-jetty](https://github.com/projecthydra/hydra-jetty), cd into its
root and run

    java -jar start.jar

Now you’re ready to run the tests. In the directory where active\_fedora
is installed, run

      rake spec

Predicate Mappings
------------------

ActiveFedora versions 2.2.1 and higher provides specialized control over
the predicate mappings used by SemanticNode. In order to provide your
own mappings, \
you must supply a predicate\_mappings.yml in the same format as the
config/predicate\_mappings.yml file shipped with the ActiveFedora gem.
Place the file in the same directory\
as your fedora.yml file and use the current method of initializing
ActiveFedora:

    ActiveFedora.init("/path/to/my/config/fedora.yml")

If no predicate\_mappings.yml file is found, ActiveFedora will use the
default mappings.

Acknowledgements
----------------

Creator: Matt Zumwalt ([MediaShelf](http://yourmediashelf.com))

Developers:
Justin Coyne, McClain Looney & Eddie Shin
([MediaShelf](http://yourmediashelf.com)), Rick Johnson (Notre Dame)

