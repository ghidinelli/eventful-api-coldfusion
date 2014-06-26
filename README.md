eventful-api-coldfusion
=======================

OAuth Eventful API Wrapper by Brian Ghidinelli, 2014
http://www.ghidinelli.com  / http://github.com/ghidinelli

To access the Eventful API using Oauth, you must:
	
1. Create an account on Eventful.com
1. Go to api.eventful.com and obtain an API app key
1. If you will be accessing Eventful on behalf of individual users, you must perform the Oauth flow for each user.  
   That means: 
  * calling getOauthRequestToken()
  * redirecting the user to the authorization_url, let them authorize you, receive the redirect back and then
  * use getOauthAccessToken() to exchange the temporary token for a permanent Access token

   If you will be accessing Eventful on behalf of your server/application, you must perform the above Oauth flow ONCE for your system.
   In this case, when you are redirected to Eventful.com's authorization_url, you will authorize with your own account
   and permanently store the resulting Access token and Access secret.
4) Make authenticated API requests using the Access token and secret acting on-behalf-of that authorized user.

Switched from the XML endpoint to JSON per my preference.


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
