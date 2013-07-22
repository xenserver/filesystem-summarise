CC = gcc
CFLAGS = -Wall -fPIC -O2 -I/usr/lib/ocaml -I./
OCAMLOPT = ocamlfind ocamlopt -package "stdext,unix,str" -thread

filesystem_summarise: filesystem_summarise.cmx filesystem_summarise_stubs.o
	$(OCAMLOPT) -linkpkg filesystem_summarise.cmx filesystem_summarise_stubs.o -o $@

%.cmx: %.ml
	$(OCAMLOPT) -c -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

install: filesystem_summarise bugtool/filesystem_summarise.xml bugtool/stuff.xml whitelist
	install -D filesystem_summarise $(DESTDIR)/opt/xensource/libexec/filesystem_summarise
	install -D bugtool/filesystem_summarise.xml $(DESTDIR)/etc/xensource/bugtool/filesystem_summarise.xml
	install -D bugtool/stuff.xml $(DESTDIR)/etc/xensource/bugtool/filesystem_summarise/stuff.xml
	install -D 05-filesystem-summarise $(DESTDIR)/etc/firstboot.d/05-filesystem-summarise
	install -D whitelist $(DESTDIR)/etc/xensource/whitelist

RPM_SOURCESDIR ?= /usr/src/redhat/SOURCES
RPM_SRPMSDIR ?= /usr/src/redhat/SRPMS

filesystem_summarise.spec: filesystem_summarise.spec.in
	sed -e 's/@RPM_RELEASE@/$(shell git rev-list HEAD | wc -l)/g' < $< > $@

srpm: filesystem_summarise.spec
	mkdir -p $(RPM_SOURCESDIR)
	git archive --prefix=filesystem_summarise-0/ --format=tar HEAD | bzip2 -z > $(RPM_SOURCESDIR)/filesystem_summarise.tar.bz2
	rpmbuild -bs --nodeps --define "_sourcedir ${RPM_SOURCESDIR}" --define "_srcrpmdir ${RPM_SRPMSDIR}" filesystem_summarise.spec

