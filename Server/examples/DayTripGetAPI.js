GetRoutes = function(app, collectionDriver) {
  this.app = app;
  this.collection = collection;

  app.get('/files/:id', function(req, res) {fileDriver.handleGet(req,res);});

  app.get('/:collection', function(req, res, next) {  
     var params = req.params;
     var query = req.query.query; //1
     if (query) {
          query = JSON.parse(query); //2
          collectionDriver.query(req.params.collection, query, returnCollectionResults(req,res)); //3
     } else {
          collectionDriver.findAll(req.params.collection, returnCollectionResults(req,res)); //4
     }
  });
   
  function returnCollectionResults(req, res) {
      return function(error, objs) { //5
          if (error) { res.send(400, error); }
            else { 
                      if (req.accepts('html')) { //6
                          res.render('data',{objects: objs, collection: req.params.collection});
                      } else {
                          res.set('Content-Type','application/json');
                          res.send(200, objs);
                  }
          }
      };
  };
   
  app.get('/:collection/:entity', function(req, res) { //I
     var params = req.params;
     var entity = params.entity;
     var collection = params.collection;
     if (entity) {
         collectionDriver.get(collection, entity, function(error, objs) { //J
            if (error) { res.send(400, error); }
            else { res.send(200, objs); } //K
         });
     } else {
        res.send(400, {error: 'bad url', url: req.url});
     }
  });

};

exports.GetRoutes = GetRoutes;