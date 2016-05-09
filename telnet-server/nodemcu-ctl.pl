#!/usr/bin/perl

# connect to NodeMCU device and upload file

use strict;
use IO::Socket::INET;
use Time::HiRes qw(sleep);

sub usage {
  die qq{Usage:
    $0 ip:port ls
    $0 ip:port put file1 file2 ...
    $0 ip:port rm file1 file2 ...
    $0 ip:port cat file1 file2 ...
    $0 ip:port mv oldname newname
    $0 ip:port reboot
};
}

$| = 1;

usage() if @ARGV < 2;

my $host = shift;

warn "Connecting to $host..\n";
my $sock = IO::Socket::INET->new($host) or die "Connect: $!";
$sock->autoflush(1);
$sock->blocking(1);

sub rcv {
  my $sleep = shift || 0.1;
  $sock->blocking(0);
  my $r;
  while ($sleep > 0) {
    print $r while $r = <$sock>;
    $sleep -= sleep 0.01;
  }
  $sock->blocking(1);
}

sub cmd {
  my $s = shift;
  my $sleep = shift || 0.1;
  print "$s\n";
  print $sock "$s\n";
  rcv($sleep);
}

my $cmds;
$cmds = {
  'ls' => sub {
    cmd 'r,u,t=file.fsinfo() print("Total : "..t.." bytes\r\nUsed  : "..u.." bytes\r\nRemain: "..r.." bytes\r\n") r=nil u=nil t=nil', 1.0;
    cmd 'for k,v in pairs(file.list()) do print(string.format("%-20s %s bytes",k,v)) end', 2.0;
  },
  'put' => sub {
    while (my $file = shift) {
      warn "Uploading $file...\n";
      open(my $fh, "<", $file) or die "Cannot open: $!";
      my $tmp = "tmp.upload";
      cmd 'file.open("'.$tmp.'","w+");', 0.5;
      cmd 'w = file.write;';
      cmd 'w([['.$_.']]);' while <$fh>;
      cmd 'file.close();', 0.5;
      cmd 'file.remove("'.$file.'")', 0.5;
      cmd 'file.rename("'.$tmp.'","'.$file.'")', 0.5;
      close $fh;
    }
    $cmds->{ls}->();
  },
  'cat' => sub {
    while (my $file = shift) {
      cmd 'if file.open("'.$file.'","r") then repeat l = file.read() print(l) until l==nil file.close() end', 3.0;
    }
  },
  'rm' => sub {
    while (my $file = shift) {
      cmd 'file.remove("'.$file.'")', 1.0;
    }
    $cmds->{ls}->();
  },
  'mv' => sub {
    my $old = shift;
    my $new = shift;
    cmd 'file.rename("'.$old.'","'.$new.'")', 1.0;
    $cmds->{ls}->();
  },
  'reboot' => sub {
    cmd 'node.restart()', 1.0;
  },
};

my $cmd = shift;
usage() unless $cmds->{$cmd};
$cmds->{$cmd}->(@ARGV);
close $sock;
