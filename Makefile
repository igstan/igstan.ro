image:
	docker build -t igstan.ro .

build: image
	docker run --rm --volume $(PWD):/opt igstan.ro jekyll build

deploy: build
	scp -r _site/* igstan.ro:/home/igstan/igstan.ro/
