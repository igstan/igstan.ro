all:
	ghc -o bin/hakyll -fforce-recomp Main.hs
	rm *.o
	rm *.hi
clean:
	rm bin/hakyll
