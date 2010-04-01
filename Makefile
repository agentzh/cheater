all: view-shopflow-hourly.php batch-shopflow-hourly.php view-catflow.php

view-%.php: %.pl
	perl $<

batch-%.php: %.pl
	perl $<

