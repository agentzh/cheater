.PHONY: old upload

all: lib/Cheater/Parser.pm

lib/Cheater/Parser.pm: grammar/cheater.grammar bin/precomp
	bin/precomp $< $@

test: all
	prove -Ilib -r t

old: view-shopflow-hourly.php \
    batch-shopflow-hourly.php \
    view-catflow.php \
    view-itemflow-percent.php \
    view-shopflow-daily.php \
    view-itemflow-top.php \
    view-itemflow-pic.php \
    view-itemflow-trend.php \
    view-admin-layout.php

view-%.php: %.pl
	perl $<

batch-%.php: %.pl
	perl $<

upload: all
	uptree .rsync

