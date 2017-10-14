using Toybox.Communications as Comm;


class GarminSDComms {
  var listener;
  var mAccelHandler = null;

  function initialize(accelHandler) {
    listener = new CommListener();
    mAccelHandler = accelHandler;
  }

  function onStart() {
    Comm.registerForPhoneAppMessages(method(:onMessageReceived));
    Comm.transmit("Hello World.", null, listener);

  }

  function sendAccelData() {
    var dataObj = {
      "HR"=> mAccelHandler.mHR,
      "X" => mAccelHandler.mSamplesX,
      "Y" => mAccelHandler.mSamplesY,
      "Z" => mAccelHandler.mSamplesZ
    };
    // FIXME - THIS CRASHED WITH OUT OF MEMORY ERROR AFTER 5 or 10 minutes.
    // Comm.transmit(dataObj,null,listener);

    // Try makeWebRequest instead to see if that avoids the memory leak
    Comm.makeWebRequest(
			"http:192.168.0.84:8080/data",
			{
			  "dataType" => "raw",
			    "data" => "[1,2,3,4,5,6,7,8,9,10]"
			    },
			{
			  :method => Communications.HTTP_REQUEST_METHOD_POST,
			    :headers => {
			    "Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
			  }
			},
			method(:onReceive));
  }

  // Receive the data from the web request
  function onReceive(responseCode, data) {
    if (responseCode == 200) {
      System.println("onReceive() success - data =");
      System.println(data);
    } else {
      System.println("onReceive() Failue - code =");
      System.println(responseCode.toString());
    }
  }
  


  function onMessageReceived(msg) {
    var i;
    System.print("GarminSdApp.onMessageReceived - ");
    System.println(msg.data.toString());
  }
  
  /////////////////////////////////////////////////////////////////////
  // Connection listener class that is used to log success and failure
  // of message transmissions.
  class CommListener extends Comm.ConnectionListener {
    function initialize() {
      Comm.ConnectionListener.initialize();
    }
    
    function onComplete() {
      System.println("Transmit Complete");
    }
    
    function onError() {
      System.println("Transmit Failed");
    }
  }

}
