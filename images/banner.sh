# brew install imagemagick
# brew install --cask font-cascadia-code
magick -size 2048x734 \
  -define gradient:angle=330 \gradient:#028cf3-#2feaa8 \
  -gravity center \
  -pointsize 100 \
  -font 'JetBrains-Mono-Bold' \
  -fill white \
  -annotate +0-80 'r-rust-pkgs' \
  -pointsize 40 \
  -font 'JetBrains-Mono-Regular' \
  -annotate +0+60 'Performance · Reliability · Productivity' \
  png:- | pngquant - --force --output images/banner.png
