How to use it

	node assets/js/dev/start
		- will start server
		- watch coffee and stylus files
		- updates deps.js
		- run tests

	node assets/js/dev/build app
		- will compile app
		- you can use --html, --one, --stage options

Install
	install NodeJS, Java, Python
	npm install -g mocha
	npm install -g stylus
	npm install -g coffee-script
	Sublimetext install: todo

TODO

	Přidat k tomu návod, co vše je třeba pro rozjetí. (instalace node, coffe, stylusu, chai, mocha globalne (možná to předělat na lokální node moduly).

	Mocha TDD output into growl (compilation too).

	Manual for TDD with Closure
		tutorial, how to fire events etc.
		rules what should be tested and what not
	
Traps

	You dont have installed Python.

	Access to protected property... from Compiler
	You probably forget to add doc comment:
	###*
		@override
	###
	Do not forget asterisk.

How to update libs

	Closure compiler is not submodule. Download it here.
	http://code.google.com/p/closure-compiler/downloads/list
