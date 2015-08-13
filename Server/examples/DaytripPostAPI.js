//This script takes an app and sets POST routes for the DayTrip REST API
DaytripModel = require('./schema');

PostRoutes = function(app) {
  this.app = app;

  app.post('/:collection', function(req, res) { 
	    console.dir(req.headers['content-type']);
	    console.dir(typeof(req.body));
	    var object = req.body;
	    var collection = req.params.collection;
	    console.log("collection: " + collection);
	    console.log(req.body);
	    switch(collection) {
	      case "POI" :
	        var poi = new DaytripModel.POI(object);
	        poi.save(function (err, poi) {
	          if (err) {
	            console.log(err);
	            return;
	          }
	          res.status(201).send(poi);
	          return;
	        });
	        break;
	    //   case "DayTrip" :
	    //     var daytrip = new DaytripModel.Daytrip(object);
	    //     daytrip.save(function (err, daytrip) {
	    //       if (err) return console.error(err);
	    //       res.send(201, daytrip);
	    //     });
	    //     break;
	    //   case "NewsItem":
	    //     var newsitem = new DaytripModel.NewsItem(object);
	    //     newsitem.save(function (err, daytrip) {
	    //       if (err) return console.error(err);
	    //       res.send(201, newsitem);
	    //     });
	    //     break; 
	    }

	    //console.warn("Post: " + req.toString());
	    //collectionDriver.save(collection, object, function(err,docs) {
	    //      if (err) { res.send(400, err); } 
	    //      else { res.send(201, docs); } //B
	    // });
	});

	app.post('/files', function(req,res) {fileDriver.handleUploadRequest(req,res);});

	// app.post('/login',
	//   passport.authenticate('local', {
	//     successRedirect: '/loginSuccess',
	//     failureRedirect: '/loginFailure'
	//   })
	// );

};



exports.PostRoutes = PostRoutes;


