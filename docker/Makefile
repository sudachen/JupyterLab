export REVISION := 1.33
export BASE_REVISION := $(REVISION)
export OWNER := sudachen

BASE = python3
DEFAULT = jupy3rlab-gpu
ALL = python3 julia11 julia11-gpu jupyterlab-gpu jupy3rlab-gpu
all: up

python3.Update:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update
julia11.Update:
	IMAGE=$(basename $@) BASE_IMAGE=python3 BASE_REVISION=latest $(MAKE) -C julia11 -f $(PWD)/Makefile.docker update
julia11-gpu.Update:
	IMAGE=$(basename $@) BASE_IMAGE=julia11 BASE_REVISION=latest $(MAKE) -C julia11/gpu -f $(PWD)/Makefile.docker update
jupyterlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=julia11-gpu BASE_REVISION=latest $(MAKE) -C jupyterlab -f $(PWD)/Makefile.docker update
jupy3rlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=jupyterlab-gpu BASE_REVISION=latest $(MAKE) -C jupy3rlab -f $(PWD)/Makefile.docker update

%.Push:
	docker push ${OWNER}/$(basename $@):${REVISION}
	docker tag ${OWNER}/$(basename $@):${REVISION} ${OWNER}/$(basename $@):latest
	docker push ${OWNER}/$(basename $@):latest
%.Pull:
	docker pull ${OWNER}/$(basename $@):${REVISION}
	docker pull ${OWNER}/$(basename $@):latest
%.Retag:  
	docker pull ${OWNER}/$(basename $@):latest
	docker tag ${OWNER}/$(basename $@):latest ${OWNER}/$(basename $@):${REVISION}
	docker push ${OWNER}/$(basename $@):${REVISION}

build:  $(DEFAULT).Build
retag:  $(foreach img, $(ALL), $(img).Retag) 
update: $(foreach img, $(ALL), $(img).Update)
push:   $(foreach img, $(ALL), $(img).Push) 
pull:   $(foreach img, $(ALL), $(img).Pull)
