package components
{
	import flash.utils.Timer;

	public class MyTimer extends Timer
	{
		public var sourceReferer:Number = -1
		
		public function MyTimer(delay:Number, repeatCount:int=0, sourceReferer:Number = 1)
		{
			this.sourceReferer = sourceReferer;
			super(delay, repeatCount);
		}
	}
}