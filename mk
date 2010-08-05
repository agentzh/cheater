.PHONY: all upload

all: lib/Cheater/Parser.pm

lib/Cheater/Parser.pm: grammar/cheater.grammar bin/precomp
	bin/precomp $< $@

test: all
	prove -Ilib -r t

upload: all
	uptree .rsync

