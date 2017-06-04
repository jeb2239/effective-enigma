
install:
	elm-package install

elmmake:
	elm-make src/Dumb.elm --output=dumb.js

client: install elmmake
	webpack

