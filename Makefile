###############################################################################
## Helpful Definitions
###############################################################################
define \n


endef

ACTIVATE = . bin/activate

###############################################################################
# Export the configuration to sub-makes
###############################################################################
export

all: test

virtualenv: bin/activate
lib: bin/activate

distclean: virtualenv-clean clean

virtualenv-clean:
	rm -rf bin include lib lib64 share src

clean:
	find . \( -name \*\.pyc \) -delete
	git clean -f -d

bin/activate:
	virtualenv --no-site-packages .
	-rm distribute*.tar.gz

freeze:
	$(ACTIVATE) && pip freeze -E . > requirements.txt

lib/python2.6/site-packages/distribute-0.6.24-py2.6.egg-info: lib
	$(ACTIVATE) && pip install -U distribute

lib/python2.6/site-packages/ez_setup.py: lib
	$(ACTIVATE) && pip install ez_setup

third_party:
	cd third_party && make

src/pip-delete-this-directory.txt: requirements.txt
	$(ACTIVATE) && pip install -E . -r requirements.txt
	touch -r requirements.txt src/pip-delete-this-directory.txt

install: lib/python2.6/site-packages/ez_setup.py lib/python2.6/site-packages/distribute-0.6.24-py2.6.egg-info third_party src/pip-delete-this-directory.txt

prepare-serve: install
	$(ACTIVATE) && python manage.py collectstatic --noinput
	$(ACTIVATE) && python manage.py syncdb

test: install
	$(ACTIVATE) && TEST_DISPLAY=1 python manage.py test -v 2 usergroup.selenium_tests.create_meeting_test

lint: install
	@# R0904 - Disable "Too many public methods" warning
	@# W0221 - Disable "Arguments differ from parent", as get and post will.
	@# E1103 - Disable "Instance of 'x' has no 'y' member (but some types could not be inferred)"
	@# I0011 - Disable "Locally disabling 'xxxx'"
	@$(ACTIVATE) && python \
		-W "ignore:disable-msg is:DeprecationWarning:pylint.lint" \
		-c "import config; config.lint_setup(); import sys; from pylint import lint; lint.Run(sys.argv[1:])" \
		--reports=n \
		--include-ids=y \
		--no-docstring-rgx "(__.*__)|(get)|(post)|(main)" \
		--indent-string='    ' \
		--disable=W0221 \
		--disable=R0904 \
		--disable=E1103 \
		--disable=I0011 \
		--const-rgx='[a-z_][a-z0-9_]{2,30}$$' *.py 2>&1 | grep -v 'maximum recursion depth exceeded'

###############################################################################
###############################################################################

config:
	$(ACTIVATE) && git-cl config file://$$PWD/.codereview.settings

upload:
	$(ACTIVATE) && git-cl upload

serve: prepare-serve install
	$(ACTIVATE) && python manage.py runserver

edit:
	$(EDITOR) *.py templates/*.html static/css/*.css

private:
	rm -rf private
	git clone git+ssh://git@github.com/mithro/slug-private.git private

.PHONY : lint upload deploy serve clean config edit private prepare-serve third_party
