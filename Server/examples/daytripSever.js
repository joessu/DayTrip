var express = require('express');
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var logger = require('morgan');
var fs = require('fs');
var bodyParser = require('body-parser');
var path = require('path');
var errorHandler = require('errorhandler');
var bCrypt = require('bcrypt-nodejs');
var mongoose = require('mongoose');
MongoClient = require('mongodb').MongoClient,
Server = require('mongodb').Server,
CollectionDriver = require('./collectionDriver').CollectionDriver;
FileDriver = require('./fileDriver').FileDriver;
DaytripModel = require('./schema');
var DaytripPostAPI = require('./DaytripPostAPI');

var fileDriver;
var collectionDriver;
var postRoutes;

//DataBase Logic
mongoose.connect('mongodb://joessu:1ForGondor@ds063160.mongolab.com:63160/daytriptest"');

var User;
var POI;
var Daytrip;
var NewsItem;
var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function (callback) {
  fileDriver = new FileDriver(db);
  User = mongoose.model('User', UserSchema);
  POI = mongoose.model('pois', POISchema);
  Daytrip = mongoose.model('Daytrip', DaytripSchema);
  NewsItem = mongoose.model('NewsItem', NewsItemSchema);

});

// MongoClient.connect("mongodb://joessu:1ForGondor@ds063160.mongolab.com:63160/daytriptest", {native_parser:true}, function(err, db) {
//   if (!db) {
//       console.error("Error! Exiting... Must start MongoDB first");
//       process.exit(1);
//   }
//   collectionDriver = new CollectionDriver(db);
//   fileDriver = new FileDriver(db);
// });
//End Database Logfic

var options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('key-cert.pem')
};

// passport.serializeUser(function(user, done) {
//   done(null, user);
// });
 
// passport.deserializeUser(function(user, done) {
//   done(null, user);
// });

// var isValidPassword = function(user, password){
//   return bCrypt.compareSync(password, user.password);
// }

// // Generates hash using bCrypt
// var createHash = function(password){
//  return bCrypt.hashSync(password, bCrypt.genSaltSync(10), null);
// }

// passport/login.js
// passport.use('login', new LocalStrategy({
//     passReqToCallback : true
//   },
//   function(req, username, password, done) { 
//     // check in mongo if a user with username exists or not
//     collectionDriver.query("Users", { 'username' :  username }, 
//       function(err, user) {
//         // In case of any error, return using the done method
//         if (err)
//           return done(err);
//         // Username does not exist, log error & redirect back
//         if (!user){
//           console.log('User Not Found with username '+ username);
//           return done(null, false, 
//                 req.flash('message', 'User Not found.'));                 
//         }
//         // User exists but wrong password, log the error 
//         if (!isValidPassword(user, password)){
//           console.log('Invalid Password');
//           return done(null, false, 
//               req.flash('message', 'Invalid Password'));
//         }
//         // User and password both match, return user from 
//         // done method which will be treated like success
//         return done(null, user);
//       }
//     );
// }));

// passport.use('signup', new LocalStrategy({
//     passReqToCallback : true
//   },
//     function(req, username, password, done) {
//       findOrCreateUser = function(){
//         // find a user in Mongo with provided username
//         collectionDriver.query("Users", {'username':username} ,function(err, user) {
//           // In case of any error return
//           if (err){
//             console.log('Error in SignUp: '+err);
//             return done(err);
//           }
//           // already exists
//           if (user) {
//             console.log('User already exists');
//             return done(null, false, 
//                req.flash('message','User Already Exists'));
//           } else {
//             // if there is no user with that email
//             // create the user
//             var newUser;
//             // set the user's local credentials
//             newUser.username = username;
//             newUser.password = createHash(password);
//             newUser.email = req.body.email;
//             newUser.firstName = req.body.firstName;
//             newUser.lastName = req.body.lastName;
   
//             // save the user
//             collectionDriver.save('Users', newUser, function(err,docs) {

//             });
//           }
//         };
      
//       }; 
//       // Delay the execution of findOrCreateUser and execute 
//       // the method in the next tick of the event loop
//       process.nextTick(findOrCreateUser);
//     });
//   );
// );

//HTTP REST API
var app = express();

app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views')); 
app.set('view engine', 'jade');
//app.use(passport.initialize());
//app.use(passport.session());
app.use(bodyParser.json());
//app.use(bodyParser.urlencoded({ extended: true }));
app.use(logger('dev'));
app.use(express.static(path.join(__dirname, 'public')));
 
 //Set Post Routes on app
postRoutes = new DaytripPostAPI(app, collectionDriver);
getRoutes = new DayTripGetAPI(app, collectionDriver);
putRoutes = new DayTripPutAPI(app, collectionDriver);
deleteRoutes = new DayTripDeleteAPI(app, collectionDriver);
// app.get('/loginFailure', function(req, res, next) {
//   res.send('Failed to authenticate');
// });
 
// app.get('/loginSuccess', function(req, res, next) {
//   res.send('Successfully authenticated');
// });



app.delete('/:collection/:entity', function(req, res) { //A
    var params = req.params;
    var entity = params.entity;
    var collection = params.collection;
    if (entity) {
       collectionDriver.delete(collection, entity, function(error, objs) { //B
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C 200 b/c includes the original doc
       });
   } else {
       var error = { "message" : "Cannot DELETE a whole collection" };
       res.send(400, error);
   }
});
 
 // error handling middleware should be loaded after the loading the routes
if ('development' == app.get('env')) {
  app.use(errorHandler());
}

app.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});