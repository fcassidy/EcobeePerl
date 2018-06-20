#!/usr/bin/perl

use LWP::Simple qw(get);
use LWP::UserAgent;
use HTTP::Tiny qw();
use strict;
use warnings;


#use JSON        qw(from_json);



#    "access_token": "aytQ0McY9p7FjJVacHXyK0DtoKcNxwDr",
#    "token_type": "Bearer",
#    "expires_in": 3599,
#    "refresh_token": "7JMivVLPz6DCsv6iZojt9rIxy8dHSX9p",
#    "scope": "smartWrite"

my $refresh_token = "74rSWLiqMIYokRhogArj8vueGZoadBLa";
my $api_key = "ffmUfLJkCfyNg6sN2lAyj4ODPZokpubL";

my $ua = LWP::UserAgent->new();

my $url  = "https://api.ecobee.com/token";
#my $data = "?grant_type=refresh_token&code=".$refresh_token."&client_id=".$api_key;

#my $req = HTTP::Request->new(POST => $url);
#my $response = $ua->post($url, $data);
#my $response = $ua->request($req);

my $response = $ua->post($url,
  ['grant_type' => 'refresh_token',
   'code' => $refresh_token,
   'client_id' => $api_key],);

print $response->decoded_content();

$response->decoded_content() =~ m/(?s)"access_token":\s*\"(\S*)\",.*?"refresh_token":\s*(\S*),/;
my $new_access_token = $1;
my $new_refresh_token = $2;

print "access = $new_access_token, refresh = $new_refresh_token\n";

#my $uri = 'https://api.ecobee.com/1/thermostat';
my $uri = 'https://api.ecobee.com/1/thermostat?format=json&body=';
my $req = HTTP::Request->new( 'GET', $uri );
$req->header('Content-Type' => 'text/json');
$req->header('Authorization' => 'Bearer '.$new_access_token);

#*  SSL certificate verify ok.
#> GET /1/thermostat?format=json&body={"selection":{"selectionType":"registered","selectionMatch":"","includeRuntime":true,"includeAlerts":true}} HTTP/1.1
#> Host: api.ecobee.com
#> User-Agent: curl/7.54.0
#> Accept: */*
#> Content-Type: text/json
#> Authorization: Bearer kOKTDWKnlv13IZ7SfhxYuxo9M6oy3Dn4
#>
#< HTTP/1.1 200 OK
#< Date: Tue, 19 Jun 2018 22:1

#my $json = "format=json&body=";
#$json .= "{\"selection\":{\"selectionType\":\"registered\",\"selectionMatch\":\"\",\"includeRuntime\":true}}";
#$req->content($json);
#my $res = $ua->request($req);

my $json = "{\"selection\":{\"selectionType\":\"registered\",\"selectionMatch\":\"\",\"includeRuntime\":true}}";

my $res = $ua->get($uri,
  'Content-Type' => 'text/json',
  'Authorization' => 'Bearer '.$new_access_token,
  'content' => $json
);
#my $response = $ua->get($denver_weather_url);


#print $req->url;
#print "\n";
#print $req->as_string;
#print "\n";
#print $req->decoded_content();

print "\n\n---------------------------------\n\n";
print $res->content;
print "\n\n---------------------------------\n\n";
print $res->decoded_content();

#'Authorization: Bearer aytQ0McY9p7FjJVacHXyK0DtoKcNxwDr' 'https://api.ecobee.com/1/thermostat?format=json&body=\{"selection":\{"selectionType":"registered","selectionMatch":"","includeRuntime":true\}\}'
