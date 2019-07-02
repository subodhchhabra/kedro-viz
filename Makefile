install: build
	cd package && python setup.py install
clean:
	rm -rf build package/dist package/kedro_viz/html pip-wheel-metadata package/kedro_viz.egg-info
	find . -regex ".*/__pycache__" -exec rm -rf {} +
	find . -regex ".*\.egg-info" -exec rm -rf {} +

package: clean install
	cd package && python setup.py clean --all
	cd package && python setup.py sdist bdist_wheel

publish:
	cd package && python3 setup.py bdist_wheel upload -r pypi-qb

run:
	python package/kedro_viz/server.py --port 4343 --logdir logs/

build: clean
	npm run build
	cp -R build package/kedro_viz/html

pytest: build
	cd package && python3 setup.py test

e2e-tests: build
	cd package && behave

pylint:
	cd package && isort
	pylint -j 0 --disable=unnecessary-pass package/kedro_viz
	pylint -j 0 --disable=missing-docstring,redefined-outer-name,no-self-use,invalid-name,too-few-public-methods,no-member package/tests
	pylint -j 0 --disable=missing-docstring,no-name-in-module package/features
	flake8 package

version:
	python3 utils/release/viz_versioning.py $(VIZ_VERSION)
	npm version $(VIZ_VERSION)