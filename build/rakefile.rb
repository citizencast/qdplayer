namespace :flash do
  desc "compile"
  task(:compile) do
    raise unless system <<-CMD \
      mxmlc ../src/flowersway.mxml \
        -output public/player.swf \
        -warnings \
        -compiler.debug \
        -strict \
        -target-player 9.0
    CMD
  end
end
