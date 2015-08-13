

var bluescape = require("bluescape");

var args;
var approvalApp = bluescape.createApplication(args);

function inputRecieved(button, input) {
	if (button.image == yesImage)
		button.setImage = noImage;
	else
		button.setImage = yesImage;
	//kinda long but....				
	button.getApp().getWidget("userLabel").setText(input.source.user.name);


	//api handles syncing of state.
	bluescape.sync(button.getApp());
}

//assets must be create via API to be represented on all
//clients
ImageData yesImage = bluescape.addAsset("url://yes.png");
ImageData noImage = bluescape.addAsset("url://no.png");

//Common Widget API
var button = bluescape.createButton("Approve");
//user who approved
var label = bluescape.createLabel("");

//widget, x = 0, y =0
approvalApp.AddWidget("button", button)
//widget, x , y
approvalApp.AddWidget("userLabel", label, 100, 50)

//simple styling example
button.setImage(image);
//events
button.setOnInput(inputRecieved);

//set up widget scene.
approvalApp.AddWidgets(button, label);





