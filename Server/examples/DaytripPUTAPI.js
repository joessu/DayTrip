
PostRoutes = function(app) {
  this.app = app;

  app.put('/:collection/:entity', function(req, res) { //A
      var params = req.params;
      var entity = params.entity;
      var collection = params.collection;
      if (entity) {
         collectionDriver.update(collection, req.body, entity, function(error, objs) { //B
            if (error) { res.send(400, error); }
            else { res.send(200, objs); } //C
         });
     } else {
         var error = { "message" : "Cannot PUT a whole collection" };
         res.send(400, error);
     }
  });

}

exports.PostRoutes = PostRoutes;