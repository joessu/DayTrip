var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var UserSchema = new Schema({
  username:  String,
  password: String,
  firstname: String,
  lastname: String,
  email:   String,
  city: String,
  dateJoined: {type: Date, default: Date.now },
  friends: [{type: Schema.Types.ObjectId, ref: "User"}],
  recentnews: [{type: Schema.Types.ObjectId, ref: "NewsItem"}]
});

var POISchema = new Schema({
  details:  String,
  categories: [String],
  name: String,
  location: {type: String, coordinates : [ Number ] },
  rating : Number,
  image: String
});

var DaytripSchema = new Schema({
	title : String,
	pois : [{type: Schema.Types.ObjectId , ref:"POI"}],
	rating : Number 
});

var NewsItemSchema = new Schema({
	description: String,
	location: { type: String, coordinates : [ Number ] },
	image: String,
	user: {type: Schema.Types.ObjectId , ref:"User"}
});

exports.User = User;
exports.POI = POI;
exports.Daytrip = Daytrip;
exports.NewsItem = NewsItem;


