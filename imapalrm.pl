#!/usr/bin/perl
# made by: KorG
# USAGE: $0 [frequency]

use strict;
use v5.18;
use warnings;
no warnings 'experimental';
use utf8;
binmode STDOUT, ':utf8';

use Net::IMAP::Simple;
use Email::Simple;
use Encode 'decode';
use WWW::Telegram::BotAPI;
use Cwd 'abs_path';

my $D = abs_path $0;
$D =~ s{/[^/]*$}{}s;

our ($host, $user, $password, %options, $token, $chat_id, $text, $mailbox);
our ($mail_subj_re);

for my $F ("$D/config.pl.sample", "$D/config.pl") {
   require $F if -f $F;
}

my $frequency = 1; # 1 check per minute
my $timeout = 10; # 10 seconds for operations
my $scale = 60; # 60 seconds
my $time_limit = $scale * ( 55 / 60 );
my $sleep;
if (defined $ARGV[0] && $ARGV[0] > 0) {
   $frequency = $ARGV[0];
}
$frequency = 55 if $frequency > $time_limit;
$sleep = $time_limit / $frequency;

sub alarm_needed {
   my $imap = Net::IMAP::Simple->new($host, %options) or die "" .
   "Connect: $Net::IMAP::Simple::errstr";

   $imap->login($user, $password) or die "Login: " . $imap->errstr;

   return $imap->unseen($mailbox) unless defined $mail_subj_re;

   return 0+ grep { m{$mail_subj_re} } map {
      decode('MIME-Header',
      Email::Simple->new(join '', @{ $imap->top($_) })->header('Subject') )
   } $imap->search('UNSEEN');
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

$SIG{ALRM} = sub { die "timeout\n" };

while ($frequency-- > 0) {
   exit if time - $^T > $time_limit;
   my $needed;
   
   eval {
      alarm $timeout;
      $needed = alarm_needed;
      alarm 0;
   };
   die $@ if $@ && $@ ne "timeout\n";
   
   eval {
      alarm $timeout;
      alarm_raise if $needed;
      alarm 0;
   };
   die $@ if $@ && $@ ne "timeout\n";
   
   sleep $sleep if $frequency;
}
