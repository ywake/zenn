run:
	npx zenn preview --open

art:
	npx zenn new:article --machine-readable | xargs code

book:
	npx zenn new:book

setup:
	npm init -y
	npm install zenn-cli
	npx zenn init

update:
	npm install zenn-cli@latest