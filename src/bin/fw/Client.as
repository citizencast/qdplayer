package bin.fw
{
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
    
    NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
	//SharedObject.defaultObjectEncoding = ObjectEncoding.AMF0;
	
	public class Client 
	{
		private var nc:NetConnection;
		
		public function Client()
		{
			nc = new NetConnection();
		    nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		    nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		    nc.client = this;
		    nc.connect("rtmp://fms.flw.kernx.com/vids");
		}
		
		public function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace(event.text);
		}
		
		public function netStatusHandler(event:NetStatusEvent):void
		{
		    switch (event.info.code)
		    {
		        case "NetConnection.Connect.Success":
		            trace("The connection was made successfully");
		            nc.call("checkBandwidth", null);
		            break;
		        case "NetConnection.Connect.Rejected":
		            trace ("Sorry, the connection was rejected");
		            break;
		        case "NetConnection.Connect.Failed":
		            trace("Failed to connect to server.");
		            break;
		    }
		}

	    public function onBWCheck(... rest):Number {
        	return 0;
	    }
	    
	    public function onBWDone(... rest):void {
	        var p_bw:Number;
	        if (rest.length > 0 && !isNaN(rest[0]))
	        {
	        	p_bw = rest[0];
	            trace("bandwidth = " + p_bw + " Kbps.");
	        }
	        nc.close();
	    }    
	     
	}
}