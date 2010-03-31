all: view-shopflow.php batch-shopflow.php view-catflow.php

view-%.php: %.pl
	perl $<

batch-%.php: %.pl
	perl $<

