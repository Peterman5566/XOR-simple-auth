# simple_auth

BASED ON: https://github.com/pauldix/service-oriented-design-with-ruby/tree/master/chapter_01

## Getting Started
if you don't have bundler installed, then please do the following:

    $ gem install bundler --version=1.0.7

Remove Gemfile.lock:

    $ rm Gemfile.lock

Then install the gems within the root of the project:

    $ bundle install

## Migrating the Database (local)
To create a local `development` or `test` database (pick one):

    $ rake db:migrate SINATRA_ENV=test
    $ rake db:migrate SINATRA_ENV=development

## Running the app (local)
 Run the Sinatra service. Use the `-e` flag, to specify `test` or `development`.
 The test environment will create a database entry

    $ ruby service.rb -e test

To view service, point browser to: http://localhost:4567/... or use curl:

    $ curl localhost:4567/api/v1/users/paul
    $ curl -X POST -H "Content-Type: application/json" -d '{"name":"Ray", "email":"soumyaray@fiction.net", "bio":"prof" }' http://localhost:4567/api/v1/users
note: the second curl command is sending a request json data in the HTTP body

## Publishing on Heroku
###Create a new Heroku app (skip if you already made one)

    $ heroku create <name-of-your-app>
You can see your app on heroku.com now.

###Send repo to Heroku:

    $ git push heroku master
notes on `git push`:
1. this will start the sinatra app running on heroku
2. no database yet -- accessing your sinatra app will cause it to crash

### Configure Heroku to run in production:

    $ heroku config:add SINATRA_ENV=production
notes on `heroku config:add`:
1. this is equivalent to local cmd: `ruby app.rb -e production`
2. adding an environment variable restarts the sinatra app on heroku

### Create the database on Heroku:

    $ heroku run rake db:migrate

You will have to restart the app now because it never connected to the database:

### Restart Sinatra app:
do this from the sinatra app's root directory:

    $ heroku restart
Your app is up and running! If it isn't, check the logs...

### Check for logged errors:

    $heroku logs

## Ignore below:
 The following does not yet work -- please ignore for now

 To test service (note, may not work on latest code version):
 rspec spec/client_spec.rb
