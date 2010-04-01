.PHONY: all upload

all: view-shopflow-hourly.php batch-shopflow-hourly.php view-catflow.php

view-%.php: %.pl
	perl $<

batch-%.php: %.pl
	perl $<

upload: all
	uptree .rsync

