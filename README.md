[express-heroku](https://github.com/Jedius/express-heroku)
=================

Simple node.js server for heroku, based on express, with sessions and oauth




Quick start
-----------

Clone the repo, `git clone https://github.com/Jedius/express-heroku`

Create account on heroku (http://www.heroku.com/)

Install heroku toolbet: `wget -qO- https://toolbelt.heroku.com/install.sh | sh`

Login: `heroku login`

Create instance: `heroku create --stack cedar`

Install redis: `heroku addons:add redistogo`

Install mongodb: `heroku addons:add mongohq:free`

Deploy: `git push heroku master`

Scale: `heroku ps:scale web=1`

See logs: `heroku logs`

Go to your application! URL you will see in console.

For auth via Facebook, you will need create app on facebook, bind redirect url, and copy id to app/assets/js/main.coffee
