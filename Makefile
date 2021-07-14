image:
	docker build -t igstan.ro .

build: image
	docker run --rm --volume $(PWD):/opt igstan.ro jekyll build

preview: image
	docker run -it --rm --volume $(PWD):/opt -p 4000:4000 igstan.ro

deploy: build
	scp -r _site/* igstan.ro:/home/igstan/igstan.ro/
