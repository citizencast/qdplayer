namespace :flash do
  desc "compile a debug version"
  task(:debug) do
    raise unless system <<-CMD \
      mxmlc ../src/flowersway.mxml \
        -output public/player.swf \
        -warnings \
        -compiler.debug \
        -strict \
        -target-player 9.0
    CMD
  end
  
  desc "compile a release version"
  task(:release) do
    raise unless system <<-CMD \
      mxmlc ../src/flowersway.mxml \
        -output release.swf \
        -warnings \
        -strict \
        -target-player 9.0
    CMD
  end
end
