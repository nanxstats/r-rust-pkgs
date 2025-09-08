# brew install imagemagick
# brew install --cask font-firago
magick -size 2048x734 \
  -define gradient:angle=330 \gradient:#028cf3-#2feaa8 \
  -gravity center \
  -pointsize 120 \
  -font 'FiraGO-SemiBold' \
  -fill white \
  -annotate +0-80 'r-rust-pkgs' \
  -pointsize 50 \
  -font 'FiraGO-Book' \
  -annotate +0+100 'Performance · Reliability · Productivity' \
  png:- | pngquant - --force --output images/banner.png
