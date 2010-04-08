.PHONY: all upload

all: view-shopflow-hourly.php \
    batch-shopflow-hourly.php \
    view-catflow.php \
    view-itemflow-percent.php \
    view-shopflow-daily.php \
    view-itemflow-top.php \
    view-itemflow-pic.php \
    view-itemflow-trend.php

view-%.php: %.pl
	perl $<

batch-%.php: %.pl
	perl $<

upload: all
	uptree .rsync

