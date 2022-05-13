if [ ! -d /usr/local/renv_cache ]; then
  mkdir -p /usr/local/renv_cache
fi

cp init_ssd_cache.sh /usr/local/bin
cp runapp /usr/local/bin
cp appshell /usr/local/bin
cp catlog /usr/local/bin

if [ ! -d /usr/share/shinybox ]; then
  mkdir -p /usr/share/shinybox
fi

cp -r ./docker /usr/share/shinybox/
