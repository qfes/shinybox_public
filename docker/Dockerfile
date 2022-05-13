ARG R_VERSION

FROM rocker/shiny:${R_VERSION}

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libssl-dev \
  libudunits2-dev \
  libgdal-dev  \
  libgeos-dev \
  libproj-dev 
  
RUN install2.r --error --skipinstalled renv

EXPOSE 3838

CMD ["/init"]

