#!/usr/bin/perl
# made by: KorG

use strict;
use v5.18;
use warnings;
no warnings 'experimental';
use utf8;
binmode STDOUT, ':utf8';

use Net::IMAP::Simple;
use WWW::Telegram::BotAPI;
use Cwd 'abs_path';

my $D = abs_path $0;
$D =~ s{/[^/]*$}{}s;

our ($host, $user, $password, %options, $token, $chat_id, $text);

for my $F ("$D/config.pl.sample", "$D/config.pl") {
   require $F if -f $F;
}

sub alarm_needed {
   my $imap = Net::IMAP::Simple->new($host, %options) or die "" .
   "Connect: $Net::IMAP::Simple::errstr";

   $imap->login($user, $password) or die "Login: " . $imap->errstr;

   $imap->unseen('INBOX')
}

sub alarm_raise {
   my $api = WWW::Telegram::BotAPI->new(
      token => $token,
   );

   $api->sendMessage({
         chat_id => $chat_id,
         text => $text,
      });
}

alarm_raise if alarm_needed;
