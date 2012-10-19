Simple node.js server for heroku, based on express, with sessions and oauth

Quick start
Clone the repo, git clone https://github.com/Jedius/express-heroku

Create account on heroku (http://www.heroku.com/)

Install heroku toolbet: wget -qO- https://toolbelt.heroku.com/install.sh | sh

Login: heroku login

Create instance: heroku create --stack cedar

Install redis: heroku addons:add redistogo

Install mongodb: heroku addons:add mongohq:free

Configure: heroku config:add NODE_ENV=production

Deploy: git push heroku master

Scale: heroku ps:scale web=1

Rename: heroku apps:rename newname

See logs: heroku logs

Go to your application! {newname}.herokuapp.com
