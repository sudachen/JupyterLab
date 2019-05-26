export REVISION := 1.32
export BASE_REVISION := $(REVISION)
export OWNER := sudachen

BASE = jupyter1
DEFAULT = jupy3rlab
ALL = jupyter1 jupyterlab jupy3rlab
all: up

jupyter1.Build:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker build
jupyter1.Update:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

jupyterlab.Build: jupyter1.Build
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
%.Up:
	$(MAKE) IMAGE=$(basename $@) -C toolbox -f $(PWD)/Makefile.up up	
%.Run: 
	$(MAKE) IMAGE=$(basename $@) -C toolbox -f $(PWD)/Makefile.up run	

build:  $(DEFAULT).Build
update: $(BASE).retag $(DEFAULT).Update
up:     $(DEFAULT).Up
push:   $(foreach img, $(ALL), $(img).Push) 
pull:   $(foreach img, $(ALL), $(img).Pull)

%.Retag:  
	docker pull ${OWNER}/$(basename $@):latest
	docker tag ${OWNER}/$(basename $@):latest ${OWNER}/$(basename $@):${REVISION}
	docker push ${OWNER}/$(basename $@):${REVISION}
down: 
	$(MAKE) -C toolbox -f $(PWD)/Makefile.up down
