var express = require('express');
var path = require('path');
var logger = require('morgan');
var fs = require('fs');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
MongoClient = require('mongodb').MongoClient,
Server = require('mongodb').Server,
FileDriver = require('./fileDriver').FileDriver;

var fileDriver;
var app = express();

//DataBase Logic
var url = "mongodb://joessu:1ForGondor@ds063160.mongolab.com:63160/daytriptest";
var db = MongoClient.connect(url, function(err, db) {
  fileDriver = new FileDriver(db);
  //User = mongoose.model('User', UserSchema);
  //POI = mongoose.model('pois', POISchema);
  //Daytrip = mongoose.model('Daytrip', DaytripSchema);
  //NewsItem = mongoose.model('NewsItem', NewsItemSchema);
});

app.set('port', process.env.PORT || 3030);
app.set('views', path.join(__dirname, 'views')); 
app.set('view engine', 'jade');
//app.use(passport.initialize());
//app.use(passport.session());
app.use(bodyParser.json());
//app.use(bodyParser.urlencoded({ extended: true }));
app.use(logger('dev'));
app.use(express.static(path.join(__dirname, 'public')));

// app.post('/:collection', function(req, res) { 
// 	    console.dir(req.headers['content-type']);
// 	    console.dir(typeof(req.body));
// 	    var object = req.body;
// 	    var collection = req.params.collection;
// 	    console.log("collection: " + collection);
// 	    console.log(req.body);
// 	    switch(collection) {
// 	      case "image" :
// 	        var poi = new DaytripModel.POI(object);
// 	        poi.save(function (err, poi) {
// 	          if (err) {
// 	            console.log(err);
// 	            return;
// 	          }
// 	          res.status(201).send(poi);
// 	          return;
// 	        });
// 	        break;
// 	    }
// 	}

app.post('/files', function(req,res) {
	console.log("file upload request");
	fileDriver.handleUploadRequest(req,res);
});

app.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
