#######################################################################################
# Dockerfile:
#   to start a template web interface using an App deployed in the A||go compute engine
#--------------------------------------------------------------------------------------
# Usage:
#   build with : docker build -t template_allgo .
#   run   with : docker run -d -p 26000:3000 --name template_allgo template_allgo
#######################################################################################

FROM node:6
MAINTAINER allgo@inria.fr

RUN npm install gulp -g
RUN npm install bower -g

#RUN git clone http://gitlab.irisa.fr/mileem/template_allgo.git
ADD . /code

RUN cd /code
RUN cd /code && npm install gulp --save-dev
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN cd /code && npm install bower --save-dev
RUN cd /code && npm install
RUN cd /code && bower --allow-root --config.interactive=false install
CMD cd /code && gulp serve

EXPOSE 3000
