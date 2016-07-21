#######################################################################################
# Dockerfile:
#   to start a template web interface using an App deployed in the A||go compute engine
#--------------------------------------------------------------------------------------
#
# Example usage:
#
#   (!) with git clone https
#   without developer access:
#      git clone https://github.com/GATB/gatb-minia-pipeline.git
#   with developer access
#      bash
#      export INRIA_FORGE_LOGIN=xxxx  
#      git clone https://${INRIA_FORGE_LOGIN}@scm.gforge.inria.fr/authscm/${INRIA_FORGE_LOGIN}/git/gatb-pipeline/gatb-pipeline.git git-https-gatb-pipeline
#
#   Then:
#      cd git-https-gatb-pipeline
#      git checkout website
#      docker build -f website/web_interface/Dockerfile -t template_allgo .
#      docker run -d -p 26000:3000 --name template_allgo template_allgo
#######################################################################################

FROM node:6
MAINTAINER allgo@inria.fr

ENV PACKAGES vim

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ${PACKAGES}

RUN npm install gulp -g
RUN npm install bower -g

#RUN git clone http://gitlab.irisa.fr/mileem/template_allgo.git
ADD . /git-gatb-pipeline

RUN ln -s /git-gatb-pipeline/website/web_interface /code
RUN cd /code 
RUN cd /code && npm install gulp --save-dev
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN cd /code && npm install bower --save-dev
RUN cd /code && npm install
RUN cd /code && bower --allow-root --config.interactive=false install
CMD cd /code && gulp serve

EXPOSE 3000
