BUILD_DATE := $(shell date +%y%m%d)
BUILD_TIME := $(shell date +%H%m%S)
BUILD_VERSION := $(shell grep version package.json | cut -c 15- | rev | cut -c 3- | rev)

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

test_web:
	npm run server:d
versiontag:
	sed -i -E 's/window.packageVersion = "\(.*\)"/window.packageVersion = "${BUILD_VERSION}"/g' index.html
	sed -i -E 's/window.buildVersion = "\(.*\)"/window.buildVersion = "${BUILD_DATE}\.${BUILD_TIME}"/g' index.html
	sed -i -E 's/\<small class="sidebar-footer" style="font-size:9px;"\>\(.*\)\<\/small\>/\<small class="sidebar-footer" style="font-size:9px;"\>${BUILD_VERSION}.${BUILD_DATE}\<\/small\>/g' ./src/components/backend-ai-pipeline.js
compile: versiontag
	npm run build
dep:
	if [ ! -d "./build/rollup/" ];then \
		make compile; \
	fi
web:
	if [ ! -d "./build/rollup/" ];then \
		make compile; \
	fi
	mkdir -p ./deploy/$(site)
	cd deploy/$(site); rm -rf ./*; mkdir console
	cp -Rp build/rollup/* deploy/$(site)/console
	cp ./configs/$(site).toml deploy/$(site)/console/config.toml
build_docker: compile
	docker build -t backend.ai-pipeline:$(BUILD_DATE) .
clean:
	cd app;	rm -rf ./backend*
	cd build;rm -rf ./unbundle ./bundle ./rollup
