<!---

	README
	
	To access the Eventful API using Oauth, you must:
	
	1) Create an account on Eventful.com
	2) Go to api.eventful.com and obtain an API app key
	3) If you will be accessing Eventful on behalf of individual users, you must perform the Oauth flow for each user.  
	   That means: a) calling getOauthRequestToken()
	   			   b) redirecting the user to the authorization_url, let them authorize you, receive the redirect back and then
	   			   C) use getOauthAccessToken() to exchange the temporary token for a permanent Access token

	   If you will be accessing Eventful on behalf of your server/application, you must perform the above Oauth flow ONCE for your system.
	   In this case, when you are redirected to Eventful.com's authorization_url, you will authorize with your own account
	   and permanently store the resulting Access token and Access secret.
	4) Make authenticated API requests using the Access token and secret acting on-behalf-of that authorized user.

	Switched from XML to JSON.
	
	
	OAuth Eventful API Wrapper by Brian Ghidinelli, 2014
	http://www.ghidinelli.com  / http://github.com/ghidinelli
	Many thanks to David Reiter @ Eventful for troubleshooting support (dreiter@eventful-inc.com)

	-----------------------------------------------------------------------

	OAuth Sample Code used from http://api.eventful.com/docs/cold_fusion
	by Travis Walter (twalters84@hotmail.com), 2012

	Original Non-OAuth Version
	by Jimmy Winter, Music Arsenal, 2008
	http://www.musicarsenal.com
	
	Based on AuthorizeNetRecurring.cfc skeleton
	by Ryan Stille, CF WebTools.
	http://www.stillnetstudios.com


   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

--->

<cfcomponent displayname="Eventful API Wrapper" hint="Access the Eventful API">

	<cfset variables.apiurl = "http://api.eventful.com/json" />

	<cffunction name="init" access="public" returntype="eventful">
		<cfargument name="restconsumer" type="any" required="true" />
		<cfargument name="app_key" required="false" type="string" hint="Application key identifies app; not required for Oauth Token Request" default="" />
		<cfargument name="consumer_key" type="string" required="true" />
		<cfargument name="consumer_secret" type="string" required="true" />
		<cfargument name="token" type="string" required="false" hint="Access token" default="" />
		<cfargument name="token_secret" type="string" required="false" hint="Access token secret" default="" />

		<cfset variables.rc = arguments.restconsumer />
		<cfset variables.app_key = arguments.app_key />
		<cfset variables.consumer_key = arguments.consumer_key />
		<cfset variables.consumer_secret = arguments.consumer_secret />
		<cfset variables.token = arguments.token />
		<cfset variables.token_secret = arguments.token_secret />
				
		<cfreturn this />
	</cffunction>

	
	<cffunction name="EventsSearch" access="public" displayname="Searches Eventful events">
		<cfargument name="keywords" required="false" type="string" default="">
		<cfargument name="location" required="false" type="string" default="">
		<cfargument name="date" required="false" type="string" default="">
		<cfargument name="category" required="false" type="string" default="">
		<cfargument name="within" required="false" type="numeric" default="0">
		<cfargument name="units" required="false" type="string" default="">
		<cfargument name="count_only" required="false" type="Boolean" default="False">
		<cfargument name="sort_order" required="false" type="string" default="Date" hint="One of 'popularity', 'date', or 'relevance'. Default is 'relevance'.">
		<cfargument name="sort_direction" required="false" type="string" default="">
		<cfargument name="page_size" required="false" type="numeric" default="0">
		<cfargument name="page_number" required="false" type="numeric" default="0">
		
		<cfset var resource = "/events/search" />
		<cfset var params = {} />
		
		<cfscript>
			if(len(arguments.keywords)) {
				structInsert(params, "keywords", arguments.keywords);
			}
			
			if(len(arguments.location)) {
				structInsert(params, "location", arguments.location);
			}
			
			if(len(arguments.date)) {
				structInsert(params, "date", arguments.date);
			}
			
			if(len(arguments.category)) {
				structInsert(params, "category", arguments.category);
			}
			
			if(len(arguments.within) AND arguments.within GT 0) {
				structInsert(params, "within", arguments.within);
			}
			
			if(len(arguments.units)) {
				structInsert(params, "units", arguments.units);
			}
			
			if(arguments.count_only) {
				structInsert(params, "count_only", arguments.count_only);
			}
			
			if(len(arguments.sort_order)) {
				structInsert(params, "sort_order", arguments.sort_order);
			}
			
			if(len(arguments.sort_direction)) {
				structInsert(params, "sort_direction", arguments.sort_direction);
			}
			 
			if(len(arguments.page_size) AND arguments.page_size GT 0) {
				structInsert(params, "page_size", arguments.page_size);
			}
			
			if(len(arguments.page_number) AND arguments.page_number GT 0) {
				structInsert(params, "page_number", arguments.page_number);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params)/>	
	</cffunction>

	
	<cffunction name="EventsNew" access="public" displayname="Creates an eventful event">
		<cfargument name="title" required="true" type="string" default="">
		<cfargument name="start_time" required="true" type="string" default="" hint="Example: 2005-07-04+17:00:00 = July 4th, 2007 5:00 PM">
		<cfargument name="stop_time" required="false" type="string" default="">
		<cfargument name="tz_olson_path" required="false" type="string" default="">
		<cfargument name="all_day" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="tags" required="false" type="string" default="">
		<cfargument name="free" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="price" required="false" type="string" default="">
		<cfargument name="venue_id" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">
		
		<cfset var resource = "/events/new"  />
		<cfset var params = {} />
		
		
		<cfscript>
			if(len(arguments.title)) {
				structInsert(params, "title", arguments.title);
			}
			
			if(len(arguments.start_time)) {
				structInsert(params, "start_time", arguments.start_time);
			}
			
			if(len(arguments.stop_time)) {
				structInsert(params, "stop_time", arguments.stop_time);
			}
			
			if(len(arguments.tz_olson_path)) {
				structInsert(params, "tz_olson_path", arguments.tz_olson_path);
			}
			
			if(len(arguments.all_day) AND arguments.all_day GT 0) {
				structInsert(params, "all_day", arguments.all_day);
			}
			
			if(len(arguments.description)) {
				structInsert(params, "description", arguments.description);
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				structInsert(params, "privacy", arguments.privacy);
			}
			
			if(len(arguments.tags)) {
				structInsert(params, "tags", arguments.tags);
			}
			 
			if(len(arguments.free) AND arguments.free GT 0) {
				structInsert(params, "free", arguments.free);
			}
			
			if(len(arguments.price)) {
				structInsert(params, "price", arguments.price);
			}
			
			if(len(arguments.venue_id)) {
				structInsert(params, "venue_id", arguments.venue_id);
			}
			
			if(len(arguments.parent_id)) {
				structInsert(params, "parent_id", arguments.parent_id);
			}
			

		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />	
	</cffunction>

	
	<cffunction name="EventsModify" access="public" displayname="Modifies an eventful event">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="title" required="false" type="string" default="">
		<cfargument name="start_time" required="false" type="string" default="" hint="Example: 2005-07-04+17:00:00 = July 4th, 2007 5:00 PM">
		<cfargument name="stop_time" required="false" type="string" default="">
		<cfargument name="tz_olson_path" required="false" type="string" default="">
		<cfargument name="all_day" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="tags" required="false" type="string" default="">
		<cfargument name="free" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="price" required="false" type="string" default="">
		<cfargument name="venue_id" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">
		
		<cfset var resource = "/events/modify"  />
		<cfset var params = {} />
		
		
		<cfscript>
			if(len(arguments.id)) {
				structInsert(params, "id", arguments.id);
			}
			
			if(len(arguments.title)) {
				structInsert(params, "title", arguments.title);
			}
			
			if(len(arguments.start_time)) {
				structInsert(params, "start_time", arguments.start_time);
			}
			
			if(len(arguments.stop_time)) {
				structInsert(params, "stop_time", arguments.stop_time);
			}
			
			if(len(arguments.tz_olson_path)) {
				structInsert(params, "tz_olson_path", arguments.tz_olson_path);
			}
			
			if(len(arguments.all_day) AND arguments.all_day GT 0) {
				structInsert(params, "all_day", arguments.all_day);
			}
			
			if(len(arguments.description)) {
				structInsert(params, "description", arguments.description);
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				structInsert(params, "privacy", arguments.privacy);
			}
			
			if(len(arguments.tags)) {
				structInsert(params, "tags", arguments.tags);
			}
			 
			if(len(arguments.free) AND arguments.free GT 0) {
				structInsert(params, "free", arguments.free);
			}
			
			if(len(arguments.price)) {
				structInsert(params, "price", arguments.price);
			}
			
			if(len(arguments.venue_id)) {
				structInsert(params, "venue_id", arguments.venue_id);
			}
			
			if(len(arguments.parent_id)) {
				structInsert(params, "parent_id", arguments.parent_id);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />	
	</cffunction>

	
	<cffunction name="EventsGet" access="public" displayname="Gets an eventful event">
		<cfargument name="id" required="true" type="string" default="">
		
		<cfset var resource = "/events/get"  />
		<cfset var params = {} />
		
		
		<cfscript>
			if(len(arguments.id)) {
				structInsert(params, "id", arguments.id);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />
	</cffunction>
	
	
	<cffunction name="EventsWithdraw" access="public" displayname="Withdraws/Deletes an eventful event">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="note" required="false" type="string" default="">
		
		<cfset var resource = "/events/withdraw"  />
		<cfset var params = {} />
		
		
		<cfscript>
			if(len(arguments.id)) {
				structInsert(params, "id", arguments.id);
			}
			
			if(len(arguments.note)) {
				structInsert(params, "note", arguments.note);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />
	</cffunction>
	
	
	<cffunction name="VenuesNew" access="public" displayname="Creates an eventful venue">
		<cfargument name="name" required="true" type="string" default="">
		<cfargument name="address" required="false" type="string" default="">
		<cfargument name="city" required="false" type="string" default="">
		<cfargument name="region" required="false" type="string" default="">
		<cfargument name="postal_code" required="false" type="string" default="">
		<cfargument name="country" required="false" type="string" default="">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="venue_type" required="false" type="string" default="">
		<cfargument name="url" required="false" type="string" default="">
		<cfargument name="url_type" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">	
		
		<cfset var resource = "/venues/new"  />
		<cfset var params = {} />
		
		
		<cfscript>
			if(len(arguments.name)) {
				structInsert(params, "name", arguments.name);
			}
			
			if(len(arguments.address)) {
				structInsert(params, "address", arguments.address);
			}
			
			if(len(arguments.city)) {
				structInsert(params, "city", arguments.city);
			}
			
			if(len(arguments.region)) {
				structInsert(params, "region", arguments.region);
			}
			
			if(len(arguments.postal_code)) {
				structInsert(params, "postal_code", arguments.postal_code);
			}
			
			if(len(arguments.country)) {
				structInsert(params, "country", arguments.country);
			}
			
			if(len(arguments.description)) {
				structInsert(params, "description", arguments.description);
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				structInsert(params, "privacy", arguments.privacy);
			}
			
			if(len(arguments.venue_type)) {
				structInsert(params, "venue_type", arguments.venue_type);
			}
			
			if(len(arguments.url)) {
				structInsert(params, "url", arguments.url);
			}
			
			if(len(arguments.url_type)) {
				structInsert(params, "url_type", arguments.url_type);
			}
			
			if(len(arguments.parent_id)) {
				structInsert(params, "parent_id", arguments.parent_id);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />	
	</cffunction>
	
	
	<cffunction name="VenuesModify" access="public" displayname="Modify an eventful venue">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="name" required="false" type="string" default="">
		<cfargument name="address" required="false" type="string" default="">
		<cfargument name="city" required="false" type="string" default="">
		<cfargument name="region" required="false" type="string" default="">
		<cfargument name="postal_code" required="false" type="string" default="">
		<cfargument name="country" required="false" type="string" default="">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="venue_type" required="false" type="string" default="">
		<cfargument name="url" required="false" type="string" default="">
		<cfargument name="url_type" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">	
		
		<cfset var resource = "/venues/modify"  />
		<cfset var params = {} />
		
		
		<cfscript>
			if(len(arguments.id)) {
				structInsert(params, "id", arguments.id);
			}
			
			if(len(arguments.name)) {
				structInsert(params, "name", arguments.name);
			}
			
			if(len(arguments.address)) {
				structInsert(params, "address", arguments.address);
			}
			
			if(len(arguments.city)) {
				structInsert(params, "city", arguments.city);
			}
			
			if(len(arguments.region)) {
				structInsert(params, "region", arguments.region);
			}
			
			if(len(arguments.postal_code)) {
				structInsert(params, "postal_code", arguments.postal_code);
			}
			
			if(len(arguments.country)) {
				structInsert(params, "country", arguments.country);
			}
			
			if(len(arguments.description)) {
				structInsert(params, "description", arguments.description);
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				structInsert(params, "privacy", arguments.privacy);
			}
			
			if(len(arguments.venue_type)) {
				structInsert(params, "venue_type", arguments.venue_type);
			}
			
			if(len(arguments.url)) {
				structInsert(params, "url", arguments.url);
			}
			
			if(len(arguments.url_type)) {
				structInsert(params, "url_type", arguments.url_type);
			}
			
			if(len(arguments.parent_id)) {
				structInsert(params, "parent_id", arguments.parent_id);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />	
	</cffunction>
	
	
	<cffunction name="VenuesGet" access="public" displayname="Gets an eventful venue">
		<cfargument name="id" required="true" type="string" default="">
		
		<cfset var resource = "/venues/get"  />
		<cfset var params = {} />
		
		<cfscript>
			if(len(arguments.id)) {
				structInsert(params, "id", arguments.id);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = arguments)/>
	</cffunction>
	
	
	<cffunction name="VenuesWithdraw" access="public" displayname="Withdraws/Deletes an eventful venue">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="note" required="false" type="string" default="">
		
		<cfset var resource = "/venues/withdraw"  />
		<cfset var params = {} />

		
		<cfscript>
			if(len(arguments.id)) {
				structInsert(params, "id", arguments.id);
			}
			
			if(len(arguments.note)) {
				structInsert(params, "note", arguments.note);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />
	</cffunction>
	
	
	<cffunction name="VenuesSearch" access="public" displayname="Searches Eventful venues">
		<cfargument name="keywords" required="false" type="string" default="">
		<cfargument name="location" required="false" type="string" default="">
		<cfargument name="within" required="false" type="numeric" default="0">
		<cfargument name="units" required="false" type="string" default="">
		<cfargument name="count_only" required="false" type="Boolean" default="False">
		<cfargument name="sort_order" required="false" type="string" default="venue_name" hint="One of 'popularity', 'relevance', or 'venue_name'. Default is 'relevance'.">
		<cfargument name="sort_direction" required="false" type="string" default="" hint="ascending or descending">
		<cfargument name="page_size" required="false" type="numeric" default="0">
		<cfargument name="page_number" required="false" type="numeric" default="0">
		
		<cfset var resource = "/venues/search"  />
		<cfset var params = {} />

		
		<cfscript>
			if(len(arguments.keywords)) {
				structInsert(params, "keywords", arguments.keywords);
			}
			
			if(len(arguments.location)) {
				structInsert(params, "location", arguments.location);
			}
			
			if(len(arguments.within) AND arguments.within GT 0) {
				structInsert(params, "within", arguments.within);
			}
			
			if(len(arguments.units)) {
				structInsert(params, "units", arguments.units);
			}
			
			if(arguments.count_only) {
				structInsert(params, "count_only", arguments.count_only);
			}
			
			if(len(arguments.sort_order)) {
				structInsert(params, "sort_order", arguments.sort_order);
			}
			
			if(len(arguments.sort_direction)) {
				structInsert(params, "sort_direction", arguments.sort_direction);
			}
			 
			if(len(arguments.page_size) AND arguments.page_size GT 0) {
				structInsert(params, "page_size", arguments.page_size);
			}
			
			if(len(arguments.page_number) AND arguments.page_number GT 0) {
				structInsert(params, "page_number", arguments.page_number);
			}
			
		</cfscript>
		
		<cfreturn doRemoteCall(resource = resource, payload = params) />	
	</cffunction>
	
	
	<cffunction name="cleanString" access="private" hint="Cleans the URL string before its sent to Eventful">
		<cfargument name="urlString" required="true" type="string">
		<cfset var retString = "">
		
		<cfscript>
			retString = replace(arguments.urlString, " ", "+", "ALL");
		</cfscript>
		
		<cfreturn retString>
	</cffunction>


	<cffunction name="doRemoteCall" output="false" access="private" returntype="any">
		<cfargument name="method" type="any" required="true" default="GET" />
		<cfargument name="resource" type="any" required="true" />
		<cfargument name="headers" type="any" required="false" default="#structNew()#" />
		<cfargument name="payload" type="any" required="false" default="#structNew()#" />

		<cfset local.uri = arguments.resource />
		<cfset local.key = "" />

		<!--- allow short /resource/style/names to add endpoint but also permit passing in a full URL like for form Submit --->
		<cfif left(uri, 1) EQ "/">
			<cfset uri = variables.apiurl & uri />
		</cfif>

		<cfif isJSON(arguments.payload) AND NOT structKeyExists(arguments.headers, "Content-Type")>
			<cfset structInsert(arguments.headers, "Content-Type", "application/json") />
		</cfif>
		
		<!--- add in the oauth / authentication fields --->
		<cfset arguments.payload["app_key"] = variables.app_key />
		<cfset arguments.payload["oauth_consumer_key"] = variables.consumer_key />
		<cfset arguments.payload["oauth_token"] = variables.token />
		<cfset arguments.payload["oauth_nonce"] = generateNonce() />
		<cfset arguments.payload["oauth_signature_method"] = "HMAC-SHA1" />
		<cfset arguments.payload["oauth_timestamp"] = generateTimestamp() />
		<cfset arguments.payload["oauth_version"] = "1.0" />

		<cfset local.signature = generateSignature(variables.consumer_secret, variables.token_secret, arguments.method, uri, arguments.payload) />
		<cfset uri &= (find("?", uri) ? "&" : "?") & "oauth_signature=#signature#" />

		<cfset local.auth_header = generateAuthorizationHeader(local.signature, arguments.payload) />
		<cfset structInsert(arguments.headers, "Authorization", local.auth_header) />

		<!--- oauth has special url encoding requirements, so use private variant and tell restconsumer NOT to encode formfields/url params --->
		<cfloop collection="#arguments.payload#" item="key">	
			<cfset uri = "#uri#&#lCase(key)#=#URLEncodedFormat_3986(arguments.payload[key])#">
		</cfloop>

		<cfset local.res = doRestCall(url = uri, method = arguments.method, payload = {}, headers = arguments.headers, encoded = false) />
		
		<!--- remove the BOM (byte order mark) from the resulting content, if it exists 
		was in original eventful.cfc, not sure if necessary now that we're using the json api?
		<cfif asc(left(res.content, 1)) EQ 65279>
			<cfset res.content = right(res.content, len(res.content)-1) />
		</cfif> 
		--->
		
		<cfif res.complete>
			<cfset res.json = isJSON(res.content) ? deserializeJson(res.content) : "" />
			<cfset res.success = isJSON(res.content) ? !structKeyExists(res.json, "error") : true />
			<cfreturn res />
		<cfelse>
			<cfdump var="#res#" output="console" />
			<cfthrow message="Error" detail="The response from #arguments.resource# was not JSON" extendedinfo="#res.content#" />
		</cfif>
		
	</cffunction>


	<cffunction name="doRestCall" output="false" access="public" returntype="any" hint="wrapper to facilitate unit testing">
		<cfreturn variables.rc.process(argumentCollection = arguments, encoded = false) />
	</cffunction>


	<cffunction name="getOauthRequestToken" output="true" access="public" returntype="any">
		<cfargument name="callback_url" type="string" required="true" />

		<cfset local.uri = "http://eventful.com/oauth/request_token" />

		<!--- add in the oauth / authentication fields --->
		<cfset arguments.payload["oauth_callback"] = arguments.callback_url />
		<cfset arguments.payload["oauth_consumer_key"] = variables.consumer_key />
		<cfset arguments.payload["oauth_nonce"] = generateNonce() />
		<cfset arguments.payload["oauth_signature_method"] = "HMAC-SHA1" />
		<cfset arguments.payload["oauth_timestamp"] = generateTimestamp() />
		<cfset arguments.payload["oauth_version"] = "1.0" />

		<cfset local.signature = generateSignature(variables.consumer_secret, "", "POST", uri, arguments.payload) />
		<cfset uri &= (find("?", uri) ? "&" : "?") & "oauth_signature=#signature#" />

		<cfset local.auth_header = generateAuthorizationHeader(local.signature, arguments.payload) />
		
		<!--- oauth has special url encoding requirements, so use private variant and tell restconsumer NOT to encode formfields/url params --->
		<cfloop collection="#arguments.payload#" item="key">	
			<cfset uri = "#uri#&#lCase(key)#=#URLEncodedFormat_3986(arguments.payload[key])#">
		</cfloop>

		<cfset local.res = doRestCall(url = uri, method = "POST", payload = {}, headers = {"Authorization": local.auth_header}, encoded = false) />

		<cfif res.complete>
			<!--- convert string to struct like: oauth_token=4e495db5fdd9304&oauth_token_secret=46b4be464964f7&oauth_callback_confirmed=true  --->
			<!--- construct the URL the user must visit to get the token --->
			<cfset res.json = {"oauth_token_secret": listLast(reMatch("oauth_token_secret=([^&]+)", res.content).get(0), "=")
								,"authorization_url": "http://eventful.com/oauth/authorize?oauth_token=" & listLast(reMatch("oauth_token=([^&]+)", res.content).get(0), "=") } />
			
			<cfset res.success = (res.status EQ 200 ? true : false) />
			<cfreturn res />
		<cfelse>
			<cfdump var="#res#" output="console" />
			<cfthrow message="Error" detail="The response from #arguments.resource# was not JSON" extendedinfo="#res.content#" />
		</cfif>
	</cffunction>


	<cffunction name="getOauthAccessToken" output="false" access="public" returntype="any" hint="After user authorizes app, exchange temporary token for a permanent access token">
		<cfargument name="oauth_token" type="string" required="true" />
		<cfargument name="oauth_token_secret" type="string" required="true" hint="One of the values returned in the original token request" />
		<cfargument name="oauth_verifier" type="string" required="true" />

		<cfset local.uri = "http://eventful.com/oauth/access_token" />

		<!--- exchange the request/temp tokens for an access token --->
		<cfset arguments.payload["oauth_token"] = arguments.oauth_token />
		<cfset arguments.payload["oauth_verifier"] = arguments.oauth_verifier />
		<!--- add in the oauth / authentication fields --->
		<cfset arguments.payload["oauth_consumer_key"] = variables.consumer_key />
		<cfset arguments.payload["oauth_nonce"] = generateNonce() />
		<cfset arguments.payload["oauth_signature_method"] = "HMAC-SHA1" />
		<cfset arguments.payload["oauth_timestamp"] = generateTimestamp() />
		<cfset arguments.payload["oauth_version"] = "1.0" />

		<cfset local.signature = generateSignature(variables.consumer_secret, arguments.oauth_token_secret, "POST", uri, arguments.payload) />
		<cfset uri &= (find("?", uri) ? "&" : "?") & "oauth_signature=#signature#" />

		<cfset local.auth_header = generateAuthorizationHeader(local.signature, arguments.payload) />
		
		<!--- oauth has special url encoding requirements, so use private variant and tell restconsumer NOT to encode formfields/url params --->
		<cfloop collection="#arguments.payload#" item="key">	
			<cfset uri = "#uri#&#lCase(key)#=#URLEncodedFormat_3986(arguments.payload[key])#">
		</cfloop>

		<cfset local.res = doRestCall(url = uri, method = "POST", payload = {}, headers = {"Authorization": local.auth_header}, encoded = false) />

		<cfif res.complete>
			<!--- convert string to struct like: oauth_token=4e495db5fdd9304&oauth_token_secret=46b4be464964f7&oauth_callback_confirmed=true  --->
			<cfset res.json = {} />
			<cfloop list="#res.content#" index="local.key" delimiters="&">
				<cfset res.json[lcase(listFirst(key, '='))] = urlDecode(listLast(key, "=")) />
			</cfloop>
			<cfset res.success = (res.status EQ 200 ? true : false) />
			<cfreturn res />
		<cfelse>
			<cfdump var="#res#" output="console" />
			<cfthrow message="Error" detail="The response from #arguments.resource# was not JSON" extendedinfo="#res.content#" />
		</cfif>

	</cffunction>


	<cffunction name="hmac_sha1" returntype="binary" access="private" output="false" hint="NSA SHA-1 Algorithm">
	   <cfargument name="signKey" type="string" required="true" />
	   <cfargument name="signMessage" type="string" required="true" />
	
	   <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
	   <cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />
	   <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
	   <cfset var mac = createObject("java","javax.crypto.Mac") />
	
	   <cfset key = key.init(jKey,"HmacSHA1") />
	   <cfset mac = mac.getInstance(key.getAlgorithm()) />
	   <cfset mac.init(key) />
	   <cfset mac.update(jMsg) />
	
	   <cfreturn mac.doFinal() />
	</cffunction>
	
	
	<cffunction name="URLEncodedFormat_3986" returntype="string" access="private" output="no">
		<cfargument name="url" type="string" required="true" />
		
		<cfset local.rfc_3986_bad_chars = "%2D,%2E,%5F,%7E" />
		<cfset local.rfc_3986_good_chars = "-,.,_,~" />
		<cfreturn replaceList(URLEncodedFormat(url),rfc_3986_bad_chars,rfc_3986_good_chars) />
	</cffunction>
	
	
	<cffunction name="OauthBaseString" returntype="string" access="private" output="no">
		<cfargument name="http_method" type="string" required="true" />
		<cfargument name="base_uri" type="string" required="true" />
		<cfargument name="parameters" type="struct" required="true" />
		
		<cfset local.oauth_signature_base_string = http_method & "&" & URLEncodedFormat_3986(base_uri) & "&" />
		<cfset local.keys_list = StructKeyList(parameters) />
		<cfset local.keys_list_sorted = ListSort(keys_list,"textnocase") />
		<cfset local.amp = "" />

		<cfloop list="#keys_list_sorted#" index="key">
			<cfset oauth_signature_base_string &= URLEncodedFormat_3986(amp & lCase(key) & "=" & URLEncodedFormat_3986(parameters[key])) />
			<cfset amp = "&" />
		</cfloop>
		
		<cfreturn oauth_signature_base_string />
	</cffunction>
	

	<cffunction name="generateSignature" output="false" access="private" returntype="any">
		<cfargument name="consumer_secret" type="string" required="true" />
		<cfargument name="token_secret" type="string" required="false" default="" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="uri" type="string" required="true" />
		<cfargument name="payload" type="struct" required="true" />

		<cfreturn URLEncodedFormat_3986(toBase64(hmac_sha1("#arguments.consumer_secret#&#arguments.token_secret#", OauthBaseString(arguments.method, arguments.uri, arguments.payload)))) />
	</cffunction>


	<cffunction name="generateAuthorizationHeader" output="false" access="private" returntype="any">
		<cfargument name="signature" type="string" required="true" />		
		<cfargument name="payload" type="struct" required="true" />

		<!--- build up the oauth authorization header --->
		<cfset local.oauth = ['OAuth realm=""', 'oauth_signature="#signature#"'] />
		<cfloop collection="#arguments.payload#" item="key">	
			<cfset arrayAppend(local.oauth, '#lCase(key)#="#arguments.payload[key]#"') />
		</cfloop>

		<cfreturn arrayToList(local.oauth, ", ") />
	</cffunction>


	<cffunction name="generateTimestamp" access="public" returntype="numeric">
		<cfset var tc = CreateObject("java", "java.util.Date").getTime() />
		<cfreturn int(tc / 1000) />
	</cffunction>


	<cffunction name="generateNonce" access="public" returntype="string" output="false" hint="generate nonce value">
		<cfset var iMin = 0 />
		<cfset var iMax = CreateObject("java","java.lang.Integer").MAX_VALUE />
		<cfset var sToEncode = generateTimestamp() & RandRange(iMin, iMax) />
		<cfreturn hash(sToEncode, "SHA") />
	</cffunction>


</cfcomponent>
