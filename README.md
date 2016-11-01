# ![classlab](web/static/assets/images/classlab-logo-with-name.png)

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/classlab/classlab/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/classlab/classlab.svg?branch=master)](https://travis-ci.org/classlab/classlab)
[![Coverage Status](https://coveralls.io/repos/github/classlab/classlab/badge.svg?branch=master)](https://coveralls.io/github/classlab/classlab?branch=master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/classlab/classlab.svg)](https://beta.hexfaktor.org/github/classlab/classlab)
[![Inline docs](http://inch-ci.org/github/classlab/classlab.svg?=123)](http://inch-ci.org/github/classlab/classlab)

Classlab is a virtual classroom for workshops.

## Installation

**Requirements**

* Elixir 1.3+
* Node 6.0+
* PostgreSQL

To start the classlab app:

  * Clone the repo with `git clone https://github.com/classlab/classlab.git`
  * Install dependencies with `mix deps.get`
  * Set up the project the first time `mix setup`
  * Install Node.js dependencies with `npm install`
  * Start the app with `mix s`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Build and run the docker demo container

build: `docker build -t classlab/classlab-demo -f Dockerfile.demo .`

run: `docker run -p 8080:80 classlab/classlab-demo`

## Team

[![Sascha Brink](http://gravatar.com/avatar/80cf026b76f105f6e03cc2955c1d21ff?s=100)](https://github.com/sbrink) | [![Martin Schurig](https://gravatar.com/avatar/d169025e2c6dbb20010a7368917c061e?s=100)](https://github.com/schurig) | [![Bengt Weisse](https://gravatar.com/avatar/236d5f3a57a66853a82cfb2fd4ab6bc9?s=100)](https://github.com/KillerCodeMonkey)
---|---|---
[Sascha Brink](https://github.com/sbrink) | [Martin Schurig](https://github.com/schurig) | [Bengt Weisse](https://github.com/KillerCodeMonkey)

## License

MIT © Symetics GmbH
