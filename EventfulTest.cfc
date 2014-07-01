<cfcomponent extends="mxunit.framework.TestCase">
	
	<cffunction name="setup">
		<cfset var beanConfigs = "" />

		<!--- standardized values for testing calculations/headers --->
		<cfset variables.oauth_consumer_secret = "oauth_consumer_secret_1111">
		<cfset variables.oauth_token_secret = "oauth_token_secret_2222">

		<cfset variables.params = {oauth_timestamp: mock_returnStaticTimestamp()
									,oauth_signature_method: "HMAC-SHA1"
									,oauth_version: "1.0"
									,app_key: "my_app_key"
									,oauth_consumer_key: "oauth_consumer_key_4444"
									,oauth_token: "oauth_token_3333"
									,oauth_nonce: mock_returnStaticNonce()
								} />

		<cfset variables.oauthparams = {oauth_timestamp: mock_returnStaticTimestamp()
									,oauth_signature_method: "HMAC-SHA1"
									,oauth_version: "1.0"
									,oauth_consumer_key: "oauth_consumer_key_4444"
									,oauth_token: "oauth_token_3333"
									,oauth_nonce: mock_returnStaticNonce()
								} />


		<!--- override with your credentials if you want to test online 
		<cfset variables.oauth_consumer_secret = "">
		<cfset variables.oauth_token_secret = "">
		<cfset variables.params["oauth_token"] = "" />
		<cfset variables.params["oauth_consumer_key"] = "" />
		<cfset variables.params["app_key"] = "" />
		--->

		<cfset variables.svc = createObject("component","eventful").init(restconsumer = createObject("component", "restconsumer").init()
																			,consumer_key = variables.params.oauth_consumer_key
																			,consumer_secret = variables.oauth_consumer_secret
																			,app_key = variables.params.app_key
																			,token = variables.params.oauth_token
																			,token_secret = variables.oauth_token_secret) />


		<!--- if set to false, will try to connect to remote service to check these all out --->
		<cfset localMode = true />

	</cffunction>


	<cffunction name="offlineInjector" access="private" hint="conditionally injects a mock if we are running tests in offline mode vs. integration mode">
		<cfif localMode>
			<cfset makePublic(arguments[1], arguments[4]) />
			<cfset injectMethod(argumentCollection = arguments) />
		</cfif>
		<!--- if not local mode, don't do any mock substitution so the service connects to the remote service! --->
	</cffunction>


	<cffunction name="testGetUserLocales">
		
		<cfset makePublic(svc, "doRemoteCall") />
		<cfset offlineInjector(svc, this, "mock_returnThunderhillWestVenue", "doRestCall") />
		<cfset local.res = svc.doRemoteCall(method = "GET", resource = "/users/locales/list", payload = {}) />

		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
	</cffunction>


	<cffunction name="testGetUserVenues">
		
		<cfset makePublic(svc, "doRemoteCall") />
		<cfset offlineInjector(svc, this, "mock_returnThunderhillWestVenue", "doRestCall") />
		<cfset local.res = svc.doRemoteCall(method = "GET", resource = "/users/venues/list", payload = {}) />

		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
	</cffunction>


	<cffunction name="testGetOauthRequestToken" output="false" access="public" returntype="any">
	
		<cfset offlineInjector(svc, this, "mock_requestToken", "doRestCall") />
		<cfset local.res = svc.getOauthRequestToken(callback_url = "http://msr.cf10/test.cfm") />
		<cfset debug(local.res) />
		
		<cfset assertTrue(local.res.status EQ 200, "The request failed and returned a #local.res.status# response") />
		<cfset assertTrue(structKeyExists(local.res.json, "authorization_url"), "There was no authorization_url constructed by the method") />
		<cfset assertTrue(structKeyExists(local.res.json, "oauth_token_secret") AND len(local.res.json.oauth_token_secret), "The oauth_token_secret wasn't returned") />
	</cffunction>


	<cffunction name="testGetOauthAccessToken" output="false" access="public" returntype="any">

		<cfset offlineInjector(svc, this, "mock_accessToken", "doRestCall") />
		<cfset local.res = svc.getOauthAccessToken(oauth_token = "efa6039474b8fe19bad8", oauth_token_secret = "432a09342a5d0e7f00c5", oauth_verifier = "2b38d10abfcba9a9d114") />
		<cfset debug(local.res) />
		
		<cfset assertTrue(local.res.status EQ 200, "The request failed and returned a #local.res.status# response") />
		<cfset assertTrue(structKeyExists(local.res.json, "oauth_token_secret") AND len(local.res.json.oauth_token_secret), "The oauth_token_secret wasn't returned") />
	</cffunction>


	<cffunction name="testOAuthBaseString" access="public" output="false" returntype="void">
		
		<cfset makePublic(svc, "OauthBaseString") />

		<cfset local.params = duplicate(variables.params) />
		<cfset local.params["id"] = "V0-001-008119466-2" />

		<cfset local.res = svc.OAuthBaseString("GET", "http://api.eventful.com/json/venues/get", local.params) />
		<cfset local.expected = "GET&http%3A%2F%2Fapi.eventful.com%2Fjson%2Fvenues%2Fget&app_key%3Dmy_app_key%26id%3DV0-001-008119466-2%26oauth_consumer_key%3Doauth_consumer_key_4444%26oauth_nonce%3D140625123211375%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1403627531%26oauth_token%3Doauth_token_3333%26oauth_version%3D1.0" />

		<cfset debug([local.expected]) />
		<cfset debug([local.res]) />

		<cfset assertTrue(local.res EQ local.expected, "The OauthBaseStrings did not match: #local.res#") />
	
	</cffunction>


	<cffunction name="testOAuthSignature" access="public" output="false" returntype="void">
		
		<cfset makePublic(svc, "generateSignature") />
		<cfset injectMethod(svc, this, "mock_returnStaticNonce", "generateNonce") />
		<cfset injectMethod(svc, this, "mock_returnStaticTimestamp", "generateTimestamp") />

		<cfset local.params = duplicate(variables.params) />
		<cfset local.params["id"] = "V0-001-008119466-2" />

		<cfset local.res = svc.generateSignature(variables.oauth_consumer_secret, variables.oauth_token_secret, "GET", "http://api.eventful.com/json/venues/get", local.params) />
		<cfset local.expected = "WlwJz7FNqmRKq%2BkEu74cMfhPVNY%3D" />

		<cfset debug([local.expected]) />
		<cfset debug([local.res]) />

		<cfset assertTrue(local.res EQ local.expected, "The Signatures did not match: #local.res#") />
	
	</cffunction>
	

	<cffunction name="testAuthorizationHeader" output="false" access="public" returntype="any">

		<cfset makePublic(svc, "generateSignature") />
		<cfset makePublic(svc, "generateAuthorizationHeader") />
		<cfset injectMethod(svc, this, "mock_returnStaticNonce", "generateNonce") />
		<cfset injectMethod(svc, this, "mock_returnStaticTimestamp", "generateTimestamp") />

		<cfset local.res = svc.generateSignature(variables.oauth_consumer_secret, variables.oauth_token_secret, "GET", "http://api.eventful.com/json/venues/get", variables.params) />
		<cfset local.res = svc.generateAuthorizationHeader(local.res, variables.params) />
		<cfset local.expected = 'OAuth realm="",oauth_timestamp="1403627531", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", app_key="my_app_key", id="V0-001-008119466-2", oauth_consumer_key="oauth_consumer_key_4444", oauth_token="oauth_token_3333", oauth_nonce="140625123211375", oauth_signature="WlwJz7FNqmRKq%2BkEu74cMfhPVNY%3D"' />

		<cfset debug([local.expected]) />
		<cfset debug([local.res]) />

		<cfset assertTrue(local.res EQ local.expected, "The OauthBaseStrings did not match: #local.res#") />
	
	</cffunction>
	
	
	<cffunction name="testAuthorizationHeaderForRequestToken" output="false" access="public" returntype="any">

		<cfset makePublic(svc, "generateSignature") />
		<cfset injectMethod(svc, this, "mock_returnStaticNonce", "generateNonce") />
		<cfset injectMethod(svc, this, "mock_returnStaticTimestamp", "generateTimestamp") />
		
		<cfset local.params = variables.oauthparams />
		<cfset local.params["oauth_callback"] = "http://msr.cf10/test.cfm" />

		<cfset local.res = svc.generateSignature(variables.oauth_consumer_secret, "", "POST", "http://eventful.com/oauth/request_token", variables.oauthparams) />
		<cfset local.expected = 'OAuth realm="",oauth_timestamp="1403627531", oauth_signature_method="HMAC-SHA1", oauth_version="1.0", oauth_callback="http%3A%2F%2Fmsr.cf10%2Ftest.cfm", id="V0-001-008119466-2", oauth_consumer_key="oauth_consumer_key_4444", oauth_token="oauth_token_3333", oauth_nonce="140625123211375", oauth_signature="WlwJz7FNqmRKq%2BkEu74cMfhPVNY%3D"' />

		<cfset debug([local.expected]) />
		<cfset debug([local.res]) />

		<cfset assertTrue(local.res EQ local.expected, "The OauthBaseStrings did not match: #local.res#") />
	
	</cffunction>	


	<cffunction name="testEventsNew" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnEventNew", "doRestCall") />
		<cfset local.res = svc.EventsNew(title = "The Lepers", start_time = "2008-10-15+21:00:00", venue_id = "V0-001-000162480-6", privacy = 2) />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(local.res.json.status EQ "ok", "The status returned was not OK: #local.res.json.status#") />
	</cffunction>


	<cffunction name="testEventsModify" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnEventModify", "doRestCall") />
		<cfset local.res = svc.EventsModify(id = "E0-001-072192067-3", title = "The Lepers Show ###randRange(1000, 9999)#") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(local.res.json.status EQ "ok", "The status returned was not OK: #local.res.json.status#") />
	</cffunction>


	<cffunction name="testEventsWithdraw" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnEventWithdraw", "doRestCall") />
		<cfset local.res = svc.EventsWithdraw(id = "E0-001-072192067-3", note = "Unit Test (Private Event)") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(local.res.json.status EQ "ok", "The status returned was not OK: #local.res.json.status#") />
	</cffunction>


	<cffunction name="testEventsGet" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnEventGet", "doRestCall") />
		<cfset local.res = svc.EventsGet(id = "E0-001-072192067-3") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(structKeyExists(local.res.json, "title"), "The result didn't have a title key") />
		<cfset assertTrue(left(local.res.json.title, 15) EQ "The Lepers Show", "The event title should begin with 'The Lepers Show', but had: #local.res.json.title#") />
	</cffunction>


	<cffunction name="testSearchEvents">
		<cfset offlineInjector(svc, this, "mock_returnEventSearch", "doRestCall") />
		<cfset local.res = svc.EventsSearch(keywords = "mazda raceway laguna seca", location = "monterey, ca, us", page_size = 1) />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(isStruct(local.res.json.events) OR (isArray(local.res.json.events) AND arrayLen(local.res.json.events) GT 0), "There should be at least one event at MRLS in Monterey, CA but found: #local.res.json.total_items#") />
	</cffunction>


	<cffunction name="testSearchEventsByLatLong">
		<cfset offlineInjector(svc, this, "mock_returnEventSearch", "doRestCall") />
		<cfset local.res = svc.EventsSearch(keywords = "", location = "36.571, -121.762", within = 2) />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(isStruct(local.res.json.events) OR (isArray(local.res.json.events) AND arrayLen(local.res.json.events) GT 0), "There should be at least one event at MRLS in Monterey, CA but found: #local.res.json.total_items#") />
	</cffunction>


	<cffunction name="testSearchEventsFindSingle">
		<cfset offlineInjector(svc, this, "mock_returnEventSearch", "doRestCall") />
		<cfset local.res = svc.EventsSearch(keywords = "outside lands", location = "37.771,-122.480", within = 3, category = "music", units = "mi", date = "2014080800-2014081000", include="price,categories,links") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(isStruct(local.res.json.events) OR (isArray(local.res.json.events) AND arrayLen(local.res.json.events) GT 0), "There should be at least one event at MRLS in Monterey, CA but found: #local.res.json.total_items#") />
	</cffunction>
	
	<cffunction name="testSearchEventsFindSingleWithOwner">
		<cfset offlineInjector(svc, this, "mock_returnEventSearch", "doRestCall") />
		<cfset local.res = svc.EventsSearch(keywords = "owner_id:21876692", location = "36.571, -121.762", within = 3, units = "mi", include="price,categories,links") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(structKeyExists(local.res.json, "events"), "There were no events returned by the search") />
		<cfset assertTrue(isStruct(local.res.json.events) OR (isArray(local.res.json.events) AND arrayLen(local.res.json.events) GT 0), "There should be at least one event at MRLS in Monterey, CA but found: #local.res.json.total_items#") />
	</cffunction>	


	<cffunction name="testSearchVenues">
		<cfset offlineInjector(svc, this, "mock_returnVenueSearch", "doRestCall") />
		<cfset local.res = svc.VenuesSearch(keywords = "mazda raceway laguna seca", location = "monterey, ca, us") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(isStruct(local.res.json.venues) OR (isArray(local.res.json.venues) AND arrayLen(local.res.json.venues) EQ 1), "There should be one MRLS in Monterey, CA but found: #local.res.json.total_items#") />
	</cffunction>


	<cffunction name="testResolveVenuesNoMatch">
		<cfset offlineInjector(svc, this, "mock_returnVenueResolveNoMatch", "doRestCall") />
		<cfset local.res = svc.VenuesResolve(location = "mazda raceway laguna seca, monterey, ca") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(structKeyExists(local.res.json, "status") AND local.res.json.status EQ "failed", "There is no match for Mazda Racweay Laguna Seca but found one: #local.res.content#") />
	</cffunction>


	<cffunction name="testResolveVenuesOneMatch">
		<cfset offlineInjector(svc, this, "mock_returnVenueResolveOneMatch", "doRestCall") />
		<cfset local.res = svc.VenuesResolve(location = "laguna seca") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(structKeyExists(local.res.json, "status") AND local.res.json.status EQ "ok", "There should be one Laguna Seca in Mexico but failed: #local.res.content#") />
	</cffunction>


	<cffunction name="testSearchVenuesByOwner">
		<cfset local.res = svc.VenuesSearch(keywords = "owner_id:21876692") />
		<cfset debug(local.res) />

		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error: #local.res.content#") />
		<cfset assertTrue(isStruct(local.res.json.venues) OR (isArray(local.res.json.venues) AND arrayLen(local.res.json.venues) GT 0), "There should be at least one venue owned by us, found: #local.res.json.total_items#") />
	</cffunction>
	
	
	<cffunction name="testVenuesNew" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnVenueNew", "doRestCall") />
		<cfset local.res = svc.VenuesNew(name = "Old Dundee", address = "4964 Dodge Street", city = "Omaha", region = "Nebraska", postal_code = "68132", country = "United States", description = "Occasional concerts", venue_type = "Bar/Night Club", privacy = 2) />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(local.res.json.status EQ "ok", "The status returned was not OK: #local.res.json.status#") />
	</cffunction>


	<cffunction name="testVenuesModify" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnVenueModify", "doRestCall") />
		<cfset local.res = svc.VenuesModify(id = "V0-001-008127088-3", title = "Old Dundee ###randRange(1000, 9999)#") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(local.res.json.status EQ "ok", "The status returned was not OK: #local.res.json.status#") />
	</cffunction>


	<cffunction name="testVenuesWithdraw" output="false" access="public" returntype="any">
		<cfset offlineInjector(svc, this, "mock_returnVenueWithdraw", "doRestCall") />
		<cfset local.res = svc.VenuesWithdraw(id = "V0-001-008127088-3", note = "Unit Test (Private Venue)") />
		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete AND isJSON(local.res.content), "Did not complete successfully, received: #local.res.content#") />
		<cfset assertTrue(local.res.json.status EQ "ok", "The status returned was not OK: #local.res.json.status#") />
	</cffunction>
	
	
	<cffunction name="testGetVenue">
		
		<cfset offlineInjector(svc, this, "mock_returnThunderhillWestVenue", "doRestCall") />
		<cfset local.res = svc.VenuesGet(id = "V0-001-008119466-2") />

		<cfset debug(local.res) />
		<cfset assertTrue(local.res.complete, "Request did not succeed") />
		<cfset assertTrue(isJson(local.res.content), "Result was not JSON") />
		<cfset assertTrue(NOT structKeyExists(local.res.json, "error"), "There was an unexpected error") />
		<cfset assertTrue(structKeyExists(local.res.json, "id") AND local.res.json.id EQ "V0-001-008119466-2", "There should be one Thunderhill West but found: #local.res.json.name#") />

		
		<cfset local.res = svc.VenuesGet("V0-001-008119466-2") />
		<cfset debug(local.res) />

	</cffunction>




	<cffunction name="mock_returnStaticNonce" output="false" access="private" returntype="boolean">
		<cfreturn "140625123211375" />	
	</cffunction>
	
	<cffunction name="mock_returnStaticTimestamp" output="false" access="private" returntype="boolean">
		<cfreturn "1403627531" />	
	</cffunction>
	
	<cffunction name="mock_returnEventNew" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"status":"ok","id":"E0-001-072192026-6","message":"Add event complete"}' } />	
	</cffunction>
	
	<cffunction name="mock_returnEventModify" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"status":"ok","id":"E0-001-072192067-3","message":"Modify event complete"}' } />	
	</cffunction>

	<cffunction name="mock_returnEventWithdraw" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"status":"ok","message":"Event withdrawn"}' } />	
	</cffunction>
	
	<cffunction name="mock_returnEventGet" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"withdrawn":"1","children":null,"comments":null,"region_abbr":"NE","postal_code":"68106","latitude":"41.2459568","all_day":"2","groups":null,"url":"http://omaha.eventful.com/events/lepers-show-9393-/E0-001-072192067-3?utm_source=apis&utm_medium=apim&utm_campaign=apic","id":"E0-001-072192067-3","address":"1322 S Saddle Creek Rd","privacy":"1","links":null,"images":null,"withdrawn_note":"Unit Test (Private Event)","longitude":"-95.9896444","country_abbr":"USA","region":"Nebraska","start_time":"2008-10-15 00:00:00","tz_id":null,"description":null,"properties":null,"recurrence":null,"modified":"2014-06-26 00:31:41","venue_display":"1","tz_country":null,"performers":null,"price":null,"title":"The Lepers Show ##9393","parents":null,"geocode_type":"EVDB Geocoder","tz_olson_path":null,"city":"Omaha","free":null,"trackbacks":null,"calendars":null,"country":"United States","owner":"motorsportreg","going":null,"country_abbr2":"US","categories":{"category":{"name":"Other &amp; Miscellaneous","id":"other"}},"tags":null,"venue_type":"Bar/Night Club","created":"2014-06-26 00:27:28","remind_user":"0","venue_id":"V0-001-000162480-6","tz_city":null,"stop_time":null,"venue_name":"O''Leavers Pub"}' } />
	</cffunction> 	

	<cffunction name="mock_returnEventSearch" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"last_item":null,"total_items":"20","first_item":null,"page_number":"1","page_size":"1","page_items":null,"search_time":"0.777","page_count":"10","events":{"event":{"watching_count":null,"calendar_count":null,"comment_count":null,"region_abbr":"CA","postal_code":null,"going_count":null,"all_day":"0","latitude":"36.5849037","groups":null,"url":"http://eventful.com/monterey_ca/events/2014-mega-mixer-/E0-001-070943486-4?utm_source=apis&utm_medium=apim&utm_campaign=apic","id":"E0-001-070943486-4","privacy":"1","city_name":"Monterey","link_count":null,"longitude":"-121.7532111","country_name":"United States","country_abbr":"USA","region_name":"California","start_time":"2014-06-26 17:30:00","tz_id":null,"description":" <p>Come join the Monterey County Young Professionals Group and the Central Coast Young Farmers</p>","modified":"2014-06-11 20:45:23","venue_display":"1","tz_country":null,"performers":null,"title":"2014 Mega Mixer","venue_address":"1021 Monterey Salinas Highway","geocode_type":"EVDB Geocoder","tz_olson_path":null,"recur_string":null,"calendars":null,"owner":"evdb","going":null,"country_abbr2":"US","image":{"small":{"width":"48","url":"http://s2.evcdn.com/images/small/I0-001/016/130/817-6.jpeg_/2014-mega-mixer-17.jpeg","height":"48"},"width":"48","caption":null,"medium":{"width":"128","url":"http://s2.evcdn.com/images/medium/I0-001/016/130/817-6.jpeg_/2014-mega-mixer-17.jpeg","height":"128"},"url":"http://s2.evcdn.com/images/small/I0-001/016/130/817-6.jpeg_/2014-mega-mixer-17.jpeg","thumb":{"width":"48","url":"http://s2.evcdn.com/images/thumb/I0-001/016/130/817-6.jpeg_/2014-mega-mixer-17.jpeg","height":"48"},"height":"48"},"created":"2014-05-21 10:26:55","venue_id":"V0-001-000112583-7","tz_city":null,"stop_time":"2014-06-26 20:30:00","venue_name":"Mazda Raceway Laguna Seca","venue_url":"http://eventful.com/monterey_ca/venues/mazda-raceway-laguna-seca-/V0-001-000112583-7?utm_source=apis&utm_medium=apim&utm_campaign=apic"}}}' } />
	</cffunction> 	

	<cffunction name="mock_returnVenueSearch" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"last_item":null,"version":"0.2","total_items":"1","first_item":null,"page_number":"1","page_size":"10","page_items":null,"search_time":"0.013","page_count":"1","venues":{"venue":{"geocode_type":"EVDB Geocoder","event_count":"17","trackback_count":"0","comment_count":"0","region_abbr":"CA","postal_code":null,"latitude":"36.5849037","url":"http://eventful.com/monterey_ca/venues/mazda-raceway-laguna-seca-/V0-001-000112583-7?utm_source=apis&utm_medium=apim&utm_campaign=apic","id":"V0-001-000112583-7","address":"1021 Monterey Salinas Highway","city_name":"Monterey","owner":"evdb","link_count":"16","country_name":"United States","longitude":"-121.7532111","timezone":null,"country_abbr":"USA","region_name":"California","country_abbr2":"US","name":"Mazda Raceway Laguna Seca","description":null,"image":{"small":{"width":"48","url":"http://s4.evcdn.com/images/small/I0-001/013/640/487-6.jpeg_/mazda-raceway-laguna-seca-87.jpeg","height":"48"},"width":"48","caption":null,"medium":{"width":"128","url":"http://s4.evcdn.com/images/medium/I0-001/013/640/487-6.jpeg_/mazda-raceway-laguna-seca-87.jpeg","height":"128"},"url":"http://s4.evcdn.com/images/small/I0-001/013/640/487-6.jpeg_/mazda-raceway-laguna-seca-87.jpeg","thumb":{"width":"48","url":"http://s4.evcdn.com/images/thumb/I0-001/013/640/487-6.jpeg_/mazda-raceway-laguna-seca-87.jpeg","height":"48"},"height":"48"},"created":null,"venue_type":"address","venue_name":"Mazda Raceway Laguna Seca"}}}' } />
	</cffunction> 	

	<cffunction name="mock_returnVenueNew" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"status":"ok","id":"V0-001-008127088-3","message":"Add venue complete"}' } />	
	</cffunction>
	
	<cffunction name="mock_returnVenueModify" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"status":"ok","id":"V0-001-008127088-3","message":"Modify venue complete"}' } />	
	</cffunction>

	<cffunction name="mock_returnVenueWithdraw" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"status":"ok","message":"Venue withdrawn"}' } />	
	</cffunction>
	
	<cffunction name="mock_returnVenueGet" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"withdrawn":null,"children":null,"comments":null,"region_abbr":"CA","postal_code":null,"latitude":"39.5244","url":"http://eventful.com/willows/venues/thunderhill-raceway-west-/V0-001-008119466-2?utm_source=apis&utm_medium=apim&utm_campaign=apic","id":"V0-001-008119466-2","address":null,"metro":null,"links":{"link":{"time":"2014-06-24 13:38:22","user_reputation":null,"url":"http://www.thunderhill.com","id":"33199259","type":"Website","description":"Official Thunderhill Website","username":"motorsportreg"}},"images":null,"withdrawn_note":null,"longitude":"-122.192","country_abbr":"USA","name":"Thunderhill Raceway West","region":"California","description":null,"properties":{"property":{"value":"1.9miles","name":"length","id":"89607"}},"modified":"2014-06-23 21:14:34","venue_display":"1","parents":null,"geocode_type":"City Based GeoCodes","tz_olson_path":null,"city":"Willows","trackbacks":null,"country":"United States","owner":"motorsportreg","country_abbr2":"US","tags":null,"venue_type":"37","created":"2014-06-23 21:14:34","events":null}' } />
	</cffunction> 	

	<cffunction name="mock_returnVenueResolveNoMatch" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"country_name":null,"location":null,"country_abbr":null,"original":"mazda raceway laguna seca, monterey, ca","country_abbr2":null,"region_name":null,"status":"failed","region_abbr":null,"venue_id":null,"where_used":null,"venue_name":null,"address":null,"venues":null,"city_name":null}' } />
	</cffunction> 	

	<cffunction name="mock_returnVenueResolveOneMatch" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"country_name":"Mexico","location":"Laguna Seca, Mexico","country_abbr":"MEX","original":"laguna seca","country_abbr2":"MX","region_name":"Puebla","status":"ok","region_abbr":"PUE","venue_id":"V0-001-008130972-3","where_used":null,"venue_name":"TBD","address":null,"venues":null,"city_name":"Laguna Seca"}' } />
	</cffunction> 	
	
	 
	
 	
	
	<!--- this mock is from restconsumer.process(), not cfhttp --->
	<cffunction name="mock_returnThunderhillWestVenue" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = '{"withdrawn":null,"children":null,"comments":null,"region_abbr":"CA","postal_code":null,"latitude":"39.5244","url":"http://eventful.com/willows/venues/thunderhill-raceway-west-/V0-001-008119466-2?utm_source=apis&utm_medium=apim&utm_campaign=apic","id":"V0-001-008119466-2","address":null,"metro":null,"links":{"link":{"time":"2014-06-24 13:38:22","user_reputation":null,"url":"http://www.thunderhill.com","id":"33199259","type":"Website","description":"Official Thunderhill Website","username":"motorsportreg"}},"images":null,"withdrawn_note":null,"longitude":"-122.192","country_abbr":"USA","name":"Thunderhill Raceway West","region":"California","description":null,"properties":{"property":{"value":"1.9miles","name":"length","id":"89607"}},"modified":"2014-06-23 21:14:34","venue_display":"1","parents":null,"geocode_type":"City Based GeoCodes","tz_olson_path":null,"city":"Willows","trackbacks":null,"country":"United States","owner":"motorsportreg","country_abbr2":"US","tags":null,"venue_type":"37","created":"2014-06-23 21:14:34","events":null}' } />	
	</cffunction>
	
	
	<cffunction name="mock_requestToken" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = 'oauth_token=efa6039474b8fe19bad8&oauth_token_secret=432a09342a5d0e7f00c5&oauth_callback_confirmed=true' } />	
	</cffunction>

	<cffunction name="mock_accessToken" output="false" access="private" returntype="any">
		<cfreturn { status = '200', Complete = true, Content = 'oauth_token=aa44d591db4a799a14a2&oauth_token_secret=f69e7f65b62bae1a6c6e' } />	
	</cffunction>
	
</cfcomponent>
