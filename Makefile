DC_TMP_IMAGE = docker-compose.image.yml
DC_TMP_RELAYLOG = docker-compose.relaylog.yml
DC_TMP_CHAT = docker-compose.chat.yml
DC_TMP_POST = docker-compose.post.yml
DC_TMP_USER = docker-compose.user.yml
DC_TMP_APIGATEWAY = docker-compose.api-gateway.yml

up: build uprelaylog upgateway
	@echo done

build:
	$(MAKE) -C fishapp-image build DC_FILE=../$(DC_TMP_IMAGE)
	$(MAKE) -C fishapp-relaylog build DC_FILE=../$(DC_TMP_RELAYLOG)
	$(MAKE) -C fishapp-chat build DC_FILE=../$(DC_TMP_CHAT)
	$(MAKE) -C fishapp-post build DC_FILE=../$(DC_TMP_POST)
	$(MAKE) -C fishapp-user build DC_FILE=../$(DC_TMP_USER)
	$(MAKE) -C fishapp-api-gateway build DC_FILE=../$(DC_TMP_APIGATEWAY)

upnats:
	$(MAKE) -C fishapp-relaylog upnats DC_FILE=../$(DC_TMP_RELAYLOG)

uppost: upnats upimage
	$(MAKE) -C fishapp-post up MIGRATE=up DC_FILE=../$(DC_TMP_POST)

upchat: upnats upimage
	$(MAKE) -C fishapp-chat up MIGRATE=up DC_FILE=../$(DC_TMP_CHAT)

upuser: upnats upimage
	$(MAKE) -C fishapp-user up MIGRATE=up DC_FILE=../$(DC_TMP_USER)

uprelaylog: uppost upchat
	$(MAKE) -C fishapp-relaylog up DC_FILE=../$(DC_TMP_RELAYLOG)

upimage:
	$(MAKE) -C fishapp-image up MIGRATE=up DC_FILE=../$(DC_TMP_IMAGE)

upgateway: upchat upuser uppost upimage upnats
	$(MAKE) -C fishapp-api-gateway up MIGRATE=up DC_FILE=../$(DC_TMP_APIGATEWAY)

pull:
	cd fishapp-post && git pull
	cd fishapp-image && git pull
	cd fishapp-relaylog && git pull
	cd fishapp-user && git pull
	cd fishapp-chat && git pull
	cd fishapp-api-gateway && git pull

# push:
# 	cd fishapp-post && git add . && git commit -m "add" && git push
# 	cd fishapp-image && git add . && git commit -m "add" && git push
# 	cd fishapp-relaylog && git add . && git commit -m "add" && git push
# 	cd fishapp-user && git add . && git commit -m "add" && git push
# 	cd fishapp-chat && git add . && git commit -m "add" && git push
# 	cd fishapp-api-gateway && git add . && git commit -m "add" && git push

down:
	$(MAKE) -C fishapp-image down DC_FILE=../$(DC_TMP_IMAGE)
	$(MAKE) -C fishapp-relaylog down DC_FILE=../$(DC_TMP_RELAYLOG)
	$(MAKE) -C fishapp-chat down DC_FILE=../$(DC_TMP_CHAT)
	$(MAKE) -C fishapp-post down DC_FILE=../$(DC_TMP_POST)
	$(MAKE) -C fishapp-user down DC_FILE=../$(DC_TMP_USER)
	$(MAKE) -C fishapp-api-gateway down DC_FILE=../$(DC_TMP_APIGATEWAY)

rmvol:
	$(MAKE) -C fishapp-image rmvol DC_FILE=../$(DC_TMP_IMAGE)
	$(MAKE) -C fishapp-relaylog rmvol DC_FILE=../$(DC_TMP_RELAYLOG)
	$(MAKE) -C fishapp-chat rmvol DC_FILE=../$(DC_TMP_CHAT)
	$(MAKE) -C fishapp-post rmvol DC_FILE=../$(DC_TMP_POST)
	$(MAKE) -C fishapp-user rmvol DC_FILE=../$(DC_TMP_USER)

# ホットリロードを無効にするためprodイメージにymlを変換
gentmp: 
	docker run --rm --name yq -v ${PWD}:/workdir mikefarah/yq sh -c " \
	cat fishapp-image/docker-compose.yml | yq d - services.image.volumes | yq d - services.image-db.ports | yq w - services.image.build.target prod | yq w - services.image.build.context fishapp-image | tee $(DC_TMP_IMAGE) && \
	cat fishapp-relaylog/docker-compose.yml | yq d - services.relaylog.volumes | yq d - services.nats-streaming.ports | yq w - services.relaylog.build.target prod | yq w - services.relaylog.build.context fishapp-relaylog | tee $(DC_TMP_RELAYLOG) && \
	cat fishapp-chat/docker-compose.yml | yq d - services.chat.volumes | yq d - services.chat-db.ports | yq w - services.chat.build.target prod | yq w - services.chat.build.context fishapp-chat | tee $(DC_TMP_CHAT) && \
	cat fishapp-post/docker-compose.yml | yq d - services.post.volumes | yq d - services.post-db.ports |yq w - services.post.build.target prod | yq w - services.post.build.context fishapp-post |  tee $(DC_TMP_POST) && \
	cat fishapp-user/docker-compose.yml | yq d - services.user.volumes | yq d - services.user-db.ports | yq w - services.user.build.target prod | yq w - services.user.build.context fishapp-user |  tee $(DC_TMP_USER) && \
	cat fishapp-api-gateway/docker-compose.yml | yq d - services.api-gateway.volumes | yq w - services.api-gateway.build.target prod | yq w - services.api-gateway.build.context fishapp-api-gateway |  tee $(DC_TMP_APIGATEWAY)"

rmtmp:
	rm -f fishapp-image/../$(DC_TMP_IMAGE)
	rm -f fishapp-relaylog/../$(DC_TMP_RELAYLOG)
	rm -f fishapp-chat/../$(DC_TMP_CHAT)
	rm -f fishapp-post/../$(DC_TMP_POST)
	rm -f fishapp-user/../$(DC_TMP_USER)
	rm -f fishapp-api-gateway/../$(DC_TMP_APIGATEWAY)