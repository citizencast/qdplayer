namespace :flash do
  desc "compile a debug version"
  task(:debug) do
    raise unless system %{
      mxmlc ../src/flowersway.mxml
        -output ../test/public/player.swf
        -warnings
        -compiler.debug
        -strict
        -target-player 9.0
    }.split.join(' ')
  end
  
  desc "compile a release version"
  task(:release) do
    #compiled it with flex4 and flash10
    raise unless system("/Applications/flex_sdk_4.0.0.13875/bin/mxmlc ../src/flowersway.mxml -output ../test/public/qdplayer.swf -warnings=false -strict -optimize=true -target-player 10.0 -compatibility-version=3.0")
    # raise unless system %{
    #     mxmlc ../src/flowersway.mxml
    #       -output release.swf
    #       -warnings
    #       -strict
    #       -target-player 9.0
    #   }.split.join(' ')
  end
end
