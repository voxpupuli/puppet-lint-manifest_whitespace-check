GEM_NAME=puppet-lint-manifest_whitespace-check
GEMSPEC_FILE=$(GEM_NAME).gemspec

define get_version
$(shell ruby -e "require 'rubygems'; load '$(GEMSPEC_FILE)'; puts Gem::Specification.all.find{|s| s.name == '$(GEM_NAME)'}.version")
endef

define get_next_patch_version
$(shell ruby -e "require 'rubygems'; load '$(GEMSPEC_FILE)'; v = Gem::Specification.all.find{|s| s.name == '$(GEM_NAME)'}.version; puts Gem::Version.new(v.version+'.0').bump")
endef

.PHONY: all clean test release

install-deps:
	bundle install

info:
	@echo "Gem name: $(GEM_NAME)"
	@echo "Spec file: $(GEMSPEC_FILE)"
	@echo "Current version: $(call get_version)"
	@echo "Next version: $(call get_next_patch_version)"

test:
	bundle exec rspec

release: patch build push-git push-gem clean

patch:
	sed "s/'$(call get_version)'/'$(call get_next_patch_version)'/" -i $(GEMSPEC_FILE)
	grep -q "'$(call get_next_patch_version)'" $(GEMSPEC_FILE)

push-git:
	git commit -m "Bump to version $(call get_next_patch_version)" -sS $(GEMSPEC_FILE)
	git push
	git tag $(call get_next_patch_version)
	git push --tags

build:
	gem build $(GEMSPEC_FILE)

push-gem:
	gem push $(GEM_NAME)-$(call get_version).gem

clean:
	rm *.gem
