run:
	npx zenn preview

art:
	npx zenn new:article

book:
	npx zenn new:book

setup:
	npm init -y
	npm install zenn-cli
	npx zenn init

update:
	npm install zenn-cli@latest