# DayTrip
DayTrip App IOS and NodeJS

The ios code should compile in xcode. I was in the middle of a massive refactor of the NodeJS server, breaking up the routes into different files and just organizing better.

This was in exercise in learning nodejs/express and also figuring out how ios communicated with a backend.

I stopped working on the project because the main usecase for it would be while on vacation, and reception is always spotty on vacation. In order for this app to work without reception (for logging trips anyways), the state must be recorded and synced whenever a connection is made. A bigger challenge is rendering map data without a connection, which could be solved by caching mapdata for a specific area (perhaps the are the person is going to). 
