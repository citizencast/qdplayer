import bin.fw.Client;

import components.MyTimer;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.events.ProgressEvent;
import flash.external.*;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;
import flash.errors.*;

import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.core.Application;
import mx.events.SliderEvent;
import mx.events.VideoEvent;

[Bindable]
public var sources:XML = new XML();
[Bindable]
public var sourceList:XMLListCollection = null;

[Bindable]
public var activeSequenceIndex:int =   0;
[Bindable]
public var contentLength:uint = 100;
[Bindable]
public var currentPosition:uint = 0;
[Bindable]
public var page:uint = 0;

public var mouseTimer:Timer;
public var timer:MyTimer;
public var cursorTimer:Timer


[Bindable(event="imageChange")]
public function imageHeight():uint
{
  var normalScreen:Boolean = Application.application.stage.displayState == StageDisplayState.NORMAL;
  if (normalScreen && image.contentHeight > image.contentWidth)
    return (2000);
  else
    return (Application.application.height);
}

[Bindable(event="imageChange")]
public function imageWidth():uint
{
  var normalScreen:Boolean = Application.application.stage.displayState == StageDisplayState.NORMAL;
  if (normalScreen && image.source.height < image.source.width)
    return (2000);
  else
    return (Application.application.width);
}

public function mouseOverMenu(event:MouseEvent):void
{
  mouseTimer.reset();
  cursorTimer.reset();
}

public function mouseOutMenu(event:MouseEvent):void
{
  mouseTimer.start();
}

public function clickOnContent(event:MouseEvent):void
{
  if (sources.source[activeSequenceIndex].type == "Video")
  {
    slider.enabled = true;
    if (videoDisplay.playing) {
      videoDisplay.pause();
      playButton.label = "4"
    }
  }
  else 
  {
    if (timer.running) {
      timer.stop();
      playButton.label = "4"
    }
  }
}

public function onMouseMove(event:MouseEvent):void
{
  showMenu();
  mouseTimer.reset();
  mouseTimer.start();
  Mouse.show();
  cursorTimer.reset();
  cursorTimer.start();
}

private function fullScreenHandler(evt:FullScreenEvent):void
{
  if (sourceList[activeSequenceIndex].type == 'Image')
  {
    image.source = new Bitmap(resize_image(images[sourceList[activeSequenceIndex].file].bitmapData));
  }  
}

public function mouseTimerEnd(event:TimerEvent):void
{
  hideMenu();
}

public function cursorTimerEnd(event:TimerEvent):void
{
  Mouse.hide();
}

public var images:Object;

private function test(e:flash.events.Event):void
{
  var loader:Loader = e.currentTarget.loader;
  images[loader.name] = loader.content;
}

private function generateRandomNumber( start:Number, end:Number ):Number
{
    var randomNum:Number;
    if( end == 1 )
    {
        randomNum = Math.random();
    }
    else{
        randomNum = Math.round( Math.random() * end );
    }
    return (randomNum);
}

private function xmlLoaded(e:Event):void
{
  sources = XML(e.target.data);
  sourceList = new XMLListCollection(sources.source);
  images = new Object();
  
  // Preload de toutes les images de la playlist
  for each (var source:XML in sourceList)
  {
    if (source.type == 'Image')
    {
      var loader:Loader = new Loader();
      loader.name = source.file;
      loader.load(new URLRequest(source.file));
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, test);
    }
  }

  var randNum = generateRandomNumber(0, sources.source.length() - 1);
  activeSequenceIndex = randNum;
  if (activeSequenceIndex >= ((page + 1) * 4))
  {
    var numPage = activeSequenceIndex / 4;
    if ((numPage % 4) != 0 ) {
      page = numPage;
    }
    else {
     page = numPage + 1; 
    }
  }


  if (sources.source[randNum].type == 'Video')
  {
    videoDisplay.source = sources.source[randNum].file;
    if (sources.source[randNum].hasOwnProperty('image'))
      image.source = sources.source[randNum].image;
    else
      image.source = sources.source[randNum].thumb;
  }
  else
  {
    image.source = sources.source[randNum].file;
    timer = new MyTimer(image_timer, image_ticks, activeSequenceIndex);
    timer.addEventListener(TimerEvent.TIMER_COMPLETE, imageEnded);
    timer.addEventListener(TimerEvent.TIMER, onImagePlay);
  }
  
  image.visible = true;
}

private function xmlErrorHandler(e:Event):void
{
  Alert.show("Unable to load Playlist", "Error!");
  playButton.enabled = false;
  nextButton.enabled = false;
  prevButton.enabled = false;
  bigPictoPlay.enabled = false;
}

public function playFilename(filename:String):void
{
  var i:uint;
  for (i = 0; i >= sources.source.length; i++)
  {
    var elem:XML = sources.source[i];
    if (elem.file == filename)
    {
      playElement(i);
      return;
    }
  }
}

public function clearVideoDisplay():void
{
  videoDisplay.close();
  videoDisplay.source = null;
  videoDisplay.mx_internal::videoPlayer.clear();
}

public function loadPlaylist(xmlFile:String):void
{
  application.parameters.playlist = xmlFile;
  page = 0;
  currentPosition = 0;
  image.visible = videoDisplay.visible = false;
  activeSequenceIndex = 0;
  progressBar.setProgress(0, 100);
  playButton.label = '4';
  progressBar.label = "00:00 / 00:00";
  clearVideoDisplay();
  
  try
  {
    var myXMLURL:URLRequest = new URLRequest(xmlFile);
    var myLoader:URLLoader = new URLLoader();
      myLoader.load(myXMLURL);
      myLoader.addEventListener("complete", xmlLoaded);
      myLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlErrorHandler);
  }
  catch (error:Error)
  {
    trace(error);
      xmlErrorHandler(new Event("catched"));
  }
  
  showMenu();
  mouseTimer = new Timer(1000, 1);
  mouseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, mouseTimerEnd);
  cursorTimer = new Timer(3000, 1);
  cursorTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cursorTimerEnd);
}

public function resetApp():void
{
  loadPlaylist(application.parameters.playlist);
}

public function initApp():void
{
  ExternalInterface.addCallback("loadPlaylist", loadPlaylist);
  ExternalInterface.addCallback("playFilename", playFilename);
  loadPlaylist(application.parameters.playlist);
  
  new Client();
  
  Application.application.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);

}

public function showMenu():void
{
  menu.visible = true;
}

public function hideMenu():void
{
  menu.visible = false;
}

public function playNextElement():void
{
  if (activeSequenceIndex + 1 < sources.source.length())
  {
    var was_stopped:Boolean = false;
    var index:uint = activeSequenceIndex + 1
    if (sourceList[index].type == 'Image' && playButton.label == "4")
    {
      was_stopped = true;
    }
    playElement(index, was_stopped)
  }
}

public function playPrevElement():void
{
  if (activeSequenceIndex > 0)
  {
    var was_stopped:Boolean = false;
    var index:uint = activeSequenceIndex - 1
    if (sourceList[index].type == 'Image' && playButton.label == "4")
    {
      was_stopped = true;
    }
    playElement(index, was_stopped);
  }
}

public function imageEnded(e:TimerEvent):void
{
  var timer:MyTimer = (MyTimer)(e.currentTarget);
  // Verifier si la lecture est toujours sur le meme element
  if (activeSequenceIndex == timer.sourceReferer)
  {
    if (activeSequenceIndex == sources.source.length() - 1)
    {
      resetApp();
    }
    else
    {
      playNextElement();
    }
  }
}

public function videoEnded(e:mx.events.VideoEvent):void
{
  if (activeSequenceIndex == sources.source.length() - 1)
  {
    resetApp();
  }
  else
  {
    playNextElement();
  }
}

public function playElement(index:Number, was_stopped:Boolean = false):void
{
  if (playButton.enabled == false)
  {
    return;
  }
  
  if (videoDisplay.playing)
  {
    videoDisplay.playheadTime = 0;
    videoDisplay.close();
  }
  if (timer)
  {
    timer.stop();
  }

  activeSequenceIndex = index;
  
  if (activeSequenceIndex >= ((page + 1) * 4))
  {
    page = page + 1;
  }
  else if (activeSequenceIndex < (page * 4))
  {
    page = page - 1;
  } 
  
  var data:XML = sources.source[index];
  var contentType:String = data.type;
  var file:String = data.file;
  
  videoName.text = data.name;
  
  if (contentType == "Video")
    playVideo(file);
  else if (contentType == "Image")
    playImage(file, was_stopped);
  else
    Alert.show("An error occurs");
}

public function clickOnElem(e:MouseEvent):void
{
  playElement(e.currentTarget.repeaterIndex + (page * 4));
}

public function playVideo(videoFile:String):void
{
  playButton.label = ';';
  image.visible = false;
  slider.enabled = true;
  
  if (videoDisplay.playing)
  {
    videoDisplay.playheadTime = 0;
    videoDisplay.close();
  }

  clearVideoDisplay();

  videoDisplay.source = videoFile;
  videoDisplay.visible = true;
  currentPosition = 0;
  videoDisplay.play();
}

public function videoReadyToPlay(e:mx.events.VideoEvent):void
{
  contentLength = videoDisplay.totalTime * (1000.0 / videoDisplay.playheadUpdateInterval);
  currentPosition = 0;
}

public function sliderMove(event:SliderEvent):void
{
  videoDisplay.pause();
}

public function onVideoLoading(event:ProgressEvent):void
{
  progressBar.setProgress(event.bytesLoaded, event.bytesTotal);
}

public function sliderHasMoved(event:SliderEvent):void
{
  var position_in_seconds:uint = (videoDisplay.totalTime / contentLength) * event.value;
  videoDisplay.playheadTime = position_in_seconds;
  clickOnPlayButton();
}

public function onVideoPlay(e:mx.events.VideoEvent):void
{
  var played:Date = new   Date(0, 0, 0, 0, 0, e.playheadTime);
  var total:Date = new   Date(0, 0, 0, 0, 0, videoDisplay.totalTime);
  progressBar.label = dateFormater.format(played) + " / " + dateFormater.format(total);
  
  currentPosition = videoDisplay.playheadTime / (videoDisplay.totalTime / contentLength);
}

public function onImagePlay(e:flash.events.TimerEvent):void
{
  currentPosition += 1;
  var seconds:uint = timer.currentCount * timer.delay / 1000;
  var total_seconds:uint = timer.repeatCount * timer.delay / 1000;
  var played:Date = new   Date(0, 0, 0, 0, 0, seconds);
  var total:Date = new   Date(0, 0, 0, 0, 0, total_seconds);
  progressBar.label = dateFormater.format(played) + " / " + dateFormater.format(total);
}

public var image_time:uint = 5;
public var image_ticks:uint = image_time * 25
public var image_timer:uint  = image_time * 1000 / image_ticks;

public function imageLoaded(e:flash.events.Event):void
{
} 

public function resize_image(bitmap:BitmapData):BitmapData
{
  var normalScreen:Boolean = Application.application.stage.displayState == StageDisplayState.NORMAL;
  if (!normalScreen)
  {
    return (bitmap);
  }
    
  var ratio_with:Number = Application.application.width / bitmap.width;
  var ratio_height:Number = Application.application.height / bitmap.height;   

  var rectangle:Rectangle;
  
  if (ratio_height < ratio_with)
  {
    rectangle = new Rectangle(
      0,
      0,
      bitmap.width,
      (ratio_height / ratio_with) * bitmap.height
    );
    rectangle.y = Math.abs((rectangle.height - bitmap.height) / 2);
  }
  else
  {
    rectangle = new Rectangle(
      0,
      0,
      (ratio_with / ratio_height) * bitmap.width,
      bitmap.height
    );
    rectangle.x = Math.abs((rectangle.width - bitmap.width) / 2);
  }
  
  var new_bitmap:BitmapData = new BitmapData(rectangle.width, rectangle.height);
  new_bitmap.copyPixels(bitmap, rectangle, new Point());
  return (new_bitmap);
}

public function playImage(imageFile:String, was_stopped:Boolean = false):void
{
  slider.enabled = false;
  videoDisplay.close();
  videoDisplay.visible = false;
  
  image.visible = true;
  image.source = new Bitmap(resize_image((Bitmap)(images[imageFile]).bitmapData));
  
  if (was_stopped == false)
  {
    playButton.label = ';';
    timer = new MyTimer(image_timer, image_ticks, activeSequenceIndex);
    timer.addEventListener(TimerEvent.TIMER_COMPLETE, imageEnded);
    timer.addEventListener(TimerEvent.TIMER, onImagePlay);
    timer.start();
  }
  
  currentPosition = 0;
  contentLength = image_ticks;
  
  progressBar.label = "00:00 / 00:00";
}

public function mouseOverThumb(e:MouseEvent):void
{
  e.currentTarget.setStyle('borderColor', 0xFF6600);
  var data:XML = sources.source[e.currentTarget.repeaterIndex + 4 * page];
  videoName.text = data.name;
  videoDescription.text = data.description;
}

public function mouseOutThumb(e:MouseEvent):void
{
  e.currentTarget.setStyle('borderColor', (e.currentTarget.repeaterIndex + 4 * page == activeSequenceIndex) ? 0xFF6600 : 0xFFFFFF);
  var data:XML = sources.source[activeSequenceIndex];
  videoName.text = data.name;
  videoDescription.text = data.description;
}

public function clickOnScreenButton():void
{
  if (Application.application.stage.displayState == StageDisplayState.NORMAL) {
    Application.application.stage.displayState = StageDisplayState.FULL_SCREEN;        
  }
  else
  {
    Application.application.stage.displayState = StageDisplayState.NORMAL;        
  }
}

public function clickOnSoundButton():void
{
  if (videoDisplay.volume > 0) {
    videoDisplay.volume = 0;
    volume.setStyle('letterSpacing', '6');
    volume.setStyle('leading', '0');
    volume.setStyle('paddingLeft', '0');
    volume.setStyle('textIndent', '0');    
    volume.label = "X";
  } else {
    videoDisplay.volume = 1;
    volume.setStyle('letterSpacing', '-1');
    volume.setStyle('leading', '1');
    volume.setStyle('paddingLeft', '2');
    volume.setStyle('textIndent', '3');    
    volume.label = "Xð";
  }
}

public function clickOnPlayButton():void
{
  if (sources.source[activeSequenceIndex].type == "Video")
  {
    slider.enabled = true;
    if (videoDisplay.playing) {
      videoDisplay.pause();
      playButton.label = "4"
    } else {
      image.visible = false;
      videoDisplay.visible = true;
      videoDisplay.play();
      playButton.label = ";";
    }
  }
  else 
  {
    if (timer.running) {
      timer.stop();
      playButton.label = "4"
    } else {
      timer.start();
      playButton.label = ";";
    }
  }
}
