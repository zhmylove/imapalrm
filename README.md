# imapalrm

imapalrm is a simple perl script to send Telegram message if there are any unseen messages on an E-Mail.

## Typical usage

Check out the latest version somethere, tune your configuration, give it appropriate permissions:

```sh
$ git clone https://github.com/zhmylove/imapalrm.git /home/user/bin/
$ cd /home/user/bin/
$ cp config.pl.sample config.pl
$ vi config.pl
$ chmod 555 imapalrm.pl
$ chmod 600 config.pl
```

And add something like the line below to your crontab(5) file.
Such a config will trigger an alarm every 30 seconds (60/2).

```
* * * * * /home/user/bin/imapalrm.pl 2
```

## Dependencies

* cpan WWW::Telegram::BotAPI
* cpan Net::IMAP::Simple
* cpan Email::Simple
