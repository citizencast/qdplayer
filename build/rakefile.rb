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
    raise unless system %{
      mxmlc ../src/flowersway.mxml
        -output release.swf
        -warnings
        -strict
        -target-player 9.0
    }.split.join(' ')
  end
end
