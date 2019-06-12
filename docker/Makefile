export SHELL=/bin/bash
export REVISION := 1.33
export OWNER := sudachen
export TAGS_DIR=$(shell pwd)/.tags

export dockerfile = Dockerfile
proxy_port = 3129
docker0 = $(shell ifconfig docker0 | awk '/inet /{ print $$2 }' )
export args = https_proxy=http://$(docker0):$(proxy_port) http_proxy=http://$(docker0):$(proxy_port)
BASE = python3
DEFAULT = jupy3rlab-gpu
ALL = python3 julia11 python3-gpu julia11-gpu jupyterlab-gpu jupy3rlab-gpu mongo-db mysql-db
PUBLIC = julia11 julia11-gpu jupy3rlab-gpu mongo-db mysql-db

all: update

python3-base.Update: 
	IMAGE=$(basename $@) \
		BASE_IMAGE= \
		dockerfile=python3-base.Dockerfile \
		$(MAKE) -C python3 -f $(PWD)/Makefile.docker update
python3.Update: python3-base.Update
	IMAGE=$(basename $@) \
		BASE_IMAGE=python3-base \
		dockerfile=python3.Dockerfile \
		$(MAKE) -C python3 -f $(PWD)/Makefile.docker update

python3-base-gpu.Update: python3-base.Update
	IMAGE=$(basename $@) \
		BASE_IMAGE=python3-base \
		dockerfile=python3-gpu.Dockerfile \
		$(MAKE) -C python3 -f $(PWD)/Makefile.docker update
python3-gpu.Update: python3-base-gpu.Update
	IMAGE=$(basename $@) \
	BASE_IMAGE=python3-base-gpu \
	dockerfile=python3.Dockerfile \
	$(MAKE) -C python3 -f $(PWD)/Makefile.docker update

julia11.Update:
	IMAGE=$(basename $@) BASE_IMAGE=python3 $(MAKE) -C julia11 -f $(PWD)/Makefile.docker update
julia11-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=python3-gpu $(MAKE) -C julia11 -f $(PWD)/Makefile.docker update
jupyterlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=julia11-gpu $(MAKE) -C jupyterlab -f $(PWD)/Makefile.docker update
jupy3rlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=jupyterlab-gpu $(MAKE) -C jupy3rlab -f $(PWD)/Makefile.docker update
mongo-db.Update:
	IMAGE=$(basename $@) $(MAKE) -C mongo -f $(PWD)/Makefile.docker update
mysql-db.Update:
	IMAGE=$(basename $@) $(MAKE) -C mysql -f $(PWD)/Makefile.docker update

squid.Update:
	args= IMAGE=$(basename $@) $(MAKE) -C squid -f $(PWD)/Makefile.docker update

%.Push:
	docker push ${OWNER}/$(basename $@):latest
	#docker tag  ${OWNER}/$(basename $@):latest ${OWNER}/$(basename $@):${REVISION}
	#docker push ${OWNER}/$(basename $@):${REVISION}
%.Pull:
	docker pull ${OWNER}/$(basename $@):latest

%.Unrev:
	docker rmi ${OWNER}/$(basename $@):${REVISION}

proxy.Up: 
	mkdir -p ${HOME}/.squid-docker-proxy
	ID=$$(docker ps -f status=running -f name=squid-docker-proxy | tail -n1 | cut -f1 -d ' ') && \
	  if [ "$${ID}" == "CONTAINER" ]; then \
	  	docker run --name squid-docker-proxy -d \
		  		   --rm \
		  		   -p $(docker0):$(proxy_port):3129 \
		           --volume ${HOME}/.squid-docker-proxy:/var/spool/squid \
				   sudachen/squid; \
	  fi

proxy.Down: 
	-docker kill squid-docker-proxy

update: proxy.Up $(foreach img, $(ALL), $(img).Update)

retag:  $(foreach img, $(PUBLIC), $(img).Retag) 
push:   $(foreach img, $(PUBLIC), $(img).Push) 
pull:   $(foreach img, $(PUBLIC), $(img).Pull)
unrev:  $(foreach img, $(ALL), $(img).Unrev)

