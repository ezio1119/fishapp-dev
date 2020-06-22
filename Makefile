DC_TMP_FILE = docker-compose.tmp.yml

up: gentmp build uprelaylog upgateway
	@echo done

build:
	$(MAKE) -C fishapp-image build DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-relaylog build DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-chat build DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-post build DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-user build DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-api-gateway build DC_FILE=$(DC_TMP_FILE)

upnats:
	$(MAKE) -C fishapp-relaylog upnats DC_FILE=$(DC_TMP_FILE)

uppost: upnats upimage
	$(MAKE) -C fishapp-post up MIGRATE=up DC_FILE=$(DC_TMP_FILE)

upchat: upnats upimage
	$(MAKE) -C fishapp-chat up MIGRATE=up DC_FILE=$(DC_TMP_FILE)

upuser: upnats upimage
	$(MAKE) -C fishapp-user up MIGRATE=up DC_FILE=$(DC_TMP_FILE)

uprelaylog: uppost upchat
	$(MAKE) -C fishapp-relaylog up DC_FILE=$(DC_TMP_FILE)

upimage:
	$(MAKE) -C fishapp-image up MIGRATE=up DC_FILE=$(DC_TMP_FILE)

upgateway: upchat upuser uppost upimage upnats
	$(MAKE) -C fishapp-api-gateway up MIGRATE=up DC_FILE=$(DC_TMP_FILE)

pull:
	cd fishapp-post && git pull
	cd fishapp-image && git pull
	cd fishapp-relaylog && git pull
	cd fishapp-user && git pull
	cd fishapp-chat && git pull
	cd fishapp-api-gateway && git pull

down:
	$(MAKE) -C fishapp-image down DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-relaylog down DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-chat down DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-post down DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-user down DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-api-gateway down DC_FILE=$(DC_TMP_FILE)

rmvol:
	$(MAKE) -C fishapp-image rmvol DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-relaylog rmvol DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-chat rmvol DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-post rmvol DC_FILE=$(DC_TMP_FILE)
	$(MAKE) -C fishapp-user rmvol DC_FILE=$(DC_TMP_FILE)

# ホットリロードを無効にするためprodイメージにymlを変換
gentmp: 
	docker run --rm --name yq -v ${PWD}:/workdir mikefarah/yq sh -c " \
	cat fishapp-post/docker-compose.yml | yq d - services.post.volumes | yq d - services.post-db.ports |yq w - services.post.build.target prod | tee fishapp-post/$(DC_TMP_FILE) && \
	cat fishapp-image/docker-compose.yml | yq d - services.image.volumes | yq d - services.image-db.ports | yq w - services.image.build.target prod | tee fishapp-image/$(DC_TMP_FILE) && \
	cat fishapp-relaylog/docker-compose.yml | yq d - services.relaylog.volumes | yq d - services.nats-streaming.ports | yq w - services.relaylog.build.target prod | tee fishapp-relaylog/$(DC_TMP_FILE) && \
	cat fishapp-user/docker-compose.yml | yq d - services.user.volumes | yq d - services.user-db.ports | yq w - services.user.build.target prod | tee fishapp-user/$(DC_TMP_FILE) && \
	cat fishapp-chat/docker-compose.yml | yq d - services.chat.volumes | yq d - services.chat-db.ports | yq w - services.chat.build.target prod | tee fishapp-chat/$(DC_TMP_FILE) && \
	cat fishapp-api-gateway/docker-compose.yml | yq d - services.api-gateway.volumes | yq w - services.api-gateway.build.target prod | tee fishapp-api-gateway/$(DC_TMP_FILE)"

rmtmp:
	rm -f fishapp-post/$(DC_TMP_FILE)
	rm -f fishapp-image/$(DC_TMP_FILE)
	rm -f fishapp-relaylog/$(DC_TMP_FILE)
	rm -f fishapp-user/$(DC_TMP_FILE)
	rm -f fishapp-chat/$(DC_TMP_FILE)
	rm -f fishapp-api-gateway/$(DC_TMP_FILE)