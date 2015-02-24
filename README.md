Typeform and Slack Integration
------------------------------

This was inspired by [Dylan](http://www.dylandamsma.com/) and https://levels.io/slack-typeform-auto-invite-sign-ups/

How to use
----------

I'm using sqlite as the database to store the typeform data, so you'd need to have the sqlite dev stuff installed:

* Debian / Ubuntu
  `sudo apt-get install libsqlite3-dev`

* RedHat / Fedora
  `sudo yum install sqlite-devel`

* MacPorts
  `sudo port install sqlite3`

* HomeBrew
  `sudo brew install sqlite`

After that, checkout this repository. Change into the checked out repo folder.

Then do `bundle install`

Copy or rename the `.env.example` file to `.env` e.g. `cp .env.example .env`

Change the contents of `.env` to your own api keys. Alternatively, you can just [create your own env vars](https://www.digitalocean.com/community/tutorials/how-to-read-and-set-environmental-and-shell-variables-on-a-linux-vps) on the server.

You can then install this into your crontab. Suggested crontab:

```
*/1 * * * * /path/to/your/repository/typeform_to_slack_worker.rb >> ~/typeform_to_slack_worker.logs

```

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request