export REVISION := 1.33
export BASE_REVISION := $(REVISION)
export OWNER := sudachen

BASE = jupyter1
DEFAULT = jupy3rlab-gpu
ALL = jupyter1 jupyter1-gpu julia1 julia1-gpu jupyterlab jupyterlab-gpu jupy3rlab-gpu
all: up

jupyter1.Build:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupyter1.Update:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

julia1.Build: jupyter1.Build
	IMAGE=$(basename $@) BASE_IMAGE=jupyter1 $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
julia1.Update:
	IMAGE=$(basename $@) BASE_IMAGE=jupyter1 BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

jupyter1-gpu.Build: jupyter1.Build
	IMAGE=$(basename $@) BASE_IMAGE=$(basename $<) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupyter1-gpu.Update:
	IMAGE=$(basename $@) BASE_IMAGE= BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

julia1-gpu.Build: jupyter1-gpu.Build
	IMAGE=$(basename $@) BASE_IMAGE=jupyter1-gpu $(MAKE) -C julia1 -f $(PWD)/Makefile.docker build
julia1-gpu.Update:
	IMAGE=$(basename $@) BASE_IMAGE=jupyter1-gpu BASE_REVISION=latest $(MAKE) -C julia1 -f $(PWD)/Makefile.docker update

jupyterlab.Build: julia1.Build
	IMAGE=$(basename $@) BASE_IMAGE=julia1 $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupyterlab.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=julia1 BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

jupyterlab-gpu.Build: julia1-gpu.Build
	IMAGE=$(basename $@) BASE_IMAGE=julia1-gpu $(MAKE) -C jupyterlab -f $(PWD)/Makefile.docker build
jupyterlab-gpu.Update: 
	IMAGE=$(basename $@) BASE_IMAGE=julia1-gpu BASE_REVISION=latest $(MAKE) -C jupyterlab -f $(PWD)/Makefile.docker update

jupy3rlab-gpu.Build: jupyterlab-gpu.Build
	IMAGE=$(basename $@) BASE_IMAGE=jupyterlab-gpu $(MAKE) -C jupy3rlab -f $(PWD)/Makefile.docker build
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
