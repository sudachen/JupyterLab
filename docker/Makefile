export REVISION := 1.33
export BASE_REVISION := $(REVISION)
export OWNER := sudachen

BASE = jupyter1
DEFAULT = jupy3rlab
ALL = jupyter1 julia1 jupyterlab jupy3rlab
all: up

jupyter1.Build:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupyter1.Update:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

julia1.Build: jupyter1.Build
	IMAGE=$(basename $@) BASE_IMAGE=$(basename $<) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
julia1.Update:
	IMAGE=$(basename $@) BASE_IMAGE= BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

jupyterlab.Build: julia1.Build
	IMAGE=$(basename $@) BASE_IMAGE=$(basename $<) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupyterlab.Update: 
	IMAGE=$(basename $@) BASE_IMAGE= BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

jupy3rlab.Build: jupyterlab.Build
	IMAGE=$(basename $@) BASE_IMAGE=$(basename $<) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupy3rlab.Update: 
	IMAGE=$(basename $@) BASE_IMAGE= BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

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
update: $(foreach img, $(ALL), $(img).Retag) $(DEFAULT).Update
push:   $(foreach img, $(ALL), $(img).Push) 
pull:   $(foreach img, $(ALL), $(img).Pull)
