#!/usr/bin/perl

use LWP::Simple qw(get);
use LWP::UserAgent;
use HTTP::Tiny qw();
use strict;
use warnings;


my $api_key;
my $refresh_token;
my $access_token;

#read access and refresh token from file
my $filename = 'tokens.dat';
open(my $fh, '+<', $filename)
  or die "Could not open file '$filename' $!";

while (my $row = <$fh>) {
  if($row =~ m/api_key:(\S*)/)
  {
    $api_key = $1;
  }

  if($row =~ m/refresh_token:(\S*)/)
  {
    $refresh_token = $1;
  }

  if($row =~ m/access_token:(\S*)/)
  {
    $access_token = $1;
  }

  print "$row\n";
}

print "access = $api_key, refresh = $refresh_token\n";

#refresh tokens
my $ua = LWP::UserAgent->new();
my $url  = "https://api.ecobee.com/token";
my $response = $ua->post($url,
  ['grant_type' => 'refresh_token',
   'code' => $refresh_token,
   'client_id' => $api_key],);

print $response->decoded_content();

$response->decoded_content() =~ m/(?s)"access_token":\s*\"(\S*)\",.*?"refresh_token":\s*\"(\S*)\",/;
my $new_access_token = $1;
my $new_refresh_token = $2;

print "access = $new_access_token, refresh = $new_refresh_token\n";

#store updated tokens to file
seek $fh, 0, 0;
print $fh "api_key:$api_key\n";
print $fh "refresh_token:$new_refresh_token\n";
print $fh "access_token:$new_access_token\n";
close($fh);

#make the request for thermostat information
my $json = "{\"selection\":{\"selectionType\":\"registered\",\"selectionMatch\":\"\",\"includeRuntime\":true,\"includeSensors\":true}}";
my $uri = 'https://api.ecobee.com/1/thermostat?format=json&body='.$json;

my $res = $ua->get($uri,
  'Content-Type' => 'text/json',
  'Authorization' => 'Bearer '.$new_access_token,
);

print "\n\n---------------------------------\n\n";
print $res->decoded_content();

#'Authorization: Bearer aytQ0McY9p7FjJVacHXyK0DtoKcNxwDr' 'https://api.ecobee.com/1/thermostat?format=json&body=\{"selection":\{"selectionType":"registered","selectionMatch":"","includeRuntime":true\}\}'
