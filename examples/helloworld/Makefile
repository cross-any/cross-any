TOPTARGETS := all clean strip install package
SUBTARGETS := all strip install
SUBDIRS := $(wildcard helloworld-*)
NAME := greet
VERSION := 1.0
ARCH := $(shell arch)

default: all

package: all strip
	mkdir -p target/opt/demos/c target/opt/demos/cpp
	install -m 0755 helloworld-c/greet*  target/opt/demos/c/
	install -m 0755 helloworld-cpp/greet*  target/opt/demos/cpp/
	mkdir -p dist
	fpm -t deb -n $(NAME) -v $(VERSION) \
		-p dist/demo-$(NAME)-VERSION_ARCH.deb -d "bash" \
		-a $(ARCH) -s dir -f \
		-C target/ .
	echo dpkg -c $@
	fpm -t rpm -n $(NAME) -v $(VERSION) \
		-p dist/demo-$(NAME)-VERSION_ARCH.rpm -d "bash" \
		-a $(ARCH) -s dir -f \
		-C target/ .
	echo rpm -qlp $@
	fpm -t zip -n $(NAME) -v $(VERSION) \
		-p dist/demo-$(NAME)-VERSION_ARCH.zip -d "bash" \
		-a $(ARCH) -s dir -f \
		-C target/ .
	echo unzip -l $@

$(SUBTARGETS):
	$(call submake,$@)
clean:
	$(call submake,$@)
	rm -rf target dist

.PHONY: $(TOPTARGETS) $(SUBDIRS)

define submake
        for d in $(SUBDIRS);                  \
        do                                    \
                $(MAKE) -C $$d $(1); \
        done
endef
