deps := deps
doc := doc
mods := mods
release := release
release_name := sneak-cam


all: doc release

clean:
	$(RM) -R $(doc)
	$(RM) -R $(release)
	
.PHONY: doc
doc:
	ldoc --dir=$(doc) mods/sneak_cam

.PHONY: release
release:
	# Prepare the directory structure.
	mkdir -p $(release)/
	mkdir -p $(release)/$(release_name)/
	mkdir -p $(release)/$(release_name)/mods/
	
	# Copy the dependencies.
	cp -R $(deps)/utils/utils $(release)/$(release_name)/mods/
	
	# Copy the mods.
	cp -R $(mods)/sneak_cam $(release)/$(release_name)/mods/
	
	# Copy the files.
	cp LICENSE $(release)/$(release_name)/
	cp README $(release)/$(release_name)/
	
	tar -c --xz -C $(release) -f $(release)/$(release_name).tar.xz $(release_name)/
	tar -c --gz -C $(release) -f $(release)/$(release_name).tar.gz $(release_name)/
	cd $(release); zip -r -9 $(release_name).zip $(release_name); cd -
	

