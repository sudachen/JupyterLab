export REVISION := 1.33
export OWNER := sudachen
export TAGS_DIR=$(shell pwd)/.tags

dockerfile = Dockerfile
args =
BASE = python3
DEFAULT = jupy3rlab-gpu
ALL = python3 julia11 julia11-gpu jupyterlab-gpu jupy3rlab-gpu mongo-db mysql-db
PUBLIC = python3 julia11 jupy3rlab-gpu mongo-db mysql-db
all: update

python3.Update:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update
julia11.Update:
	IMAGE=$(basename $@) BASE_IMAGE=python3 $(MAKE) -C julia11 -f $(PWD)/Makefile.docker update
python3-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=python3 dockerfile=Dockerfile.python3-gpu $(MAKE) -C julia11 -f $(PWD)/Makefile.docker update
julia11-gpu.Update: python3-gpu.Update
	IMAGE=$(basename $@) BASE_IMAGE=python3-gpu $(MAKE) -C julia11 -f $(PWD)/Makefile.docker update
jupyterlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=julia11-gpu $(MAKE) -C jupyterlab -f $(PWD)/Makefile.docker update
jupy3rlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=jupyterlab-gpu $(MAKE) -C jupy3rlab -f $(PWD)/Makefile.docker update
mongo-db.Update:
	IMAGE=$(basename $@) $(MAKE) -C mongo -f $(PWD)/Makefile.docker update
mysql-db.Update:
	IMAGE=$(basename $@) $(MAKE) -C mysql -f $(PWD)/Makefile.docker update

%.Push:
	docker push ${OWNER}/$(basename $@):latest
	#docker tag  ${OWNER}/$(basename $@):latest ${OWNER}/$(basename $@):${REVISION}
	#docker push ${OWNER}/$(basename $@):${REVISION}
%.Pull:
	docker pull ${OWNER}/$(basename $@):latest

%.Unrev:
	docker rmi ${OWNER}/$(basename $@):${REVISION}

build:  $(DEFAULT).Build
retag:  $(foreach img, $(PUBLIC), $(img).Retag) 
update: $(foreach img, $(ALL), $(img).Update)
push:   $(foreach img, $(PUBLIC), $(img).Push) 
pull:   $(foreach img, $(PUBLIC), $(img).Pull)
unrev:  $(foreach img, $(ALL), $(img).Unrev)
