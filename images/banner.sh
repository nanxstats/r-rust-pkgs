# brew install imagemagick
# brew install --cask font-cascadia-code
magick -size 2048x734 \
  -define gradient:angle=330 \gradient:#ff5acd-#fbda61 \
  -gravity center \
  -pointsize 100 \
  -font 'Cascadia-Code-SemiBold' \
  -fill white \
  -annotate +0-80 'r-rust-pkgs' \
  -pointsize 40 \
  -font 'Cascadia-Code-SemiBold' \
  -annotate +0+60 'Performance · Reliability · Productivity' \
  png:- | pngquant - --force --output images/banner.png
