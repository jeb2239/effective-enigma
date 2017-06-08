# Effective Enigma

This is a chat based RPG game.


The UI is made using [Elm](http://elm-lang.org/) and the backend is done using [loopback](http://loopback.io/)

## Running the Game in Browser

https://effective-enigma.mybluemix.net/index.html

## Important notes

### Client Implementations
 - Web (uses elm)
 - Android (incomplete)

### Loopback
  * Models:
    * User
      * Some Define ACLs
    * Note
    * Game State
  * Data Source:
    * IBM Bluemix Cloudant NoSQL DB

### IBM Watson
  * Used [Watson Conversation](https://www.ibm.com/watson/developercloud/conversation.html?S_PKG=AW&cm_mmc=Search_Google-_-Watson+Core_Watson+Core+-+Engagement-_-WW_NA-_-watson+ibm+conversation+service_Broad_AW&cm_mmca1=000018SW&cm_mmca2=10004432&mkwid=55f34ffb-1998-451a-81af-1ebd39a81c1a|484|21062&cvosrc=ppc.google.watson%20ibm%20conversation%20service&cvo_campaign=Watson%20Core_Watson%20Core%20-%20Engagement-WW_NA&cvo_crid=191764234282&Matchtype=b)


## Basic Architecture
 * A Game State is initialized in the DB and the App when a new user logs in 
 * User posts a message on the web app which is then sent to IBM Watson with the relevant game state info
 * Watson responds appropriatly
 * The Game State is updated in the app and the DB through loopback


<a href="http://www.wtfpl.net/"><img
       src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl-badge-4.png"
       width="80" height="15" alt="WTFPL" /></a>
