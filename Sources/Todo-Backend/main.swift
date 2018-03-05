import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import MySQLStORM
import StORM
import PerfectTurnstileMySQL
import TurnstilePerfect

// Create HTTP server.
let server = HTTPServer()

// Register routes and handlers
let authWebRoutes = makeWebAuthRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
server.addRoutes(authWebRoutes)
server.addRoutes(authJSONRoutes)

// Set the connection properties for the MySQL Server
// Change to suit your specific environment
MDDatabase.share.startPostgresConector()

// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfectRealm()

// Set up the Authentication table if it doesn't exist
let auth = AuthAccount()
try? auth.setup()

// Connect the AccessTokenStore and setup table if it doesn't exist
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

// add routes to be excluded from auth check
let routePaths = RoutingPath()

var authenticationConfig = AuthenticationConfig()
authenticationConfig.exclude([routePaths.login, routePaths.register])
// add routes to be checked for auth
authenticationConfig.include([routePaths.count, routePaths.getAll, routePaths.create, routePaths.update, routePaths.delete])

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

// Setup main API
let routes = Routing()
server.addRoutes(Routes(routes.getRoutes))

// Set a listen port of 8181
server.serverPort = 8181

do {
    // Launch the servers based on the configuration data.
    try server.start()
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}

