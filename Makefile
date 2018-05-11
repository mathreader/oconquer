main:
	ocamlbuild -use-ocamlfind src/main.byte

test:
	ocamlbuild -use-ocamlfind src/test.byte && ./test.byte

build:
	mkdir -p programs/out
	mkdir -p programs/out-temp
	mkdir -p programs/dist
	cd web-app; npm install && npm run build
	ocamlbuild -use-ocamlfind src/main.byte

docs:
	mkdir -p docs
	ocamldoc -html -d docs/ -colorize-code -short-functors -stars -keep-code \
	-I ~/.opam/4.06.0/lib/cohttp/ -I ~/.opam/4.06.0/lib/ocaml/ \
	-I ~/.opam/4.06.0/lib/yojson/ -I ~/.opam/4.06.0/lib/ounit/ \
	-I _build/src/ \
	src/*.ml[i]

cleandocs:
	rm -rf ./docs

zip:
	zip submission.zip \
	*.ml* ./programs/src/* ./web-app/* _tags Makefile .merlin .ocamlinit *.md \
	-x ./web-app/node_modules/*

clean:
	ocamlbuild -clean
	rm -f submission.zip
	rm -rf ./docs
