version: '2'
services:
  reaction:
    image: "${REACTION_IMAGE}"
    restart: always
    labels:
      io.rancher.scheduler.affinity:host_label: ${host_label}
      traefik.enable: 'true'
      traefik.alias: '${REACTION_HOST}'
      traefik.domain: '${REACTION_DOMAIN}'
      traefik.acme: 'true'
      traefik.port: '3000'
    environment:
      ROOT_URL: "http://${REACTION_HOST}.${REACTION_DOMAIN}"
      MONGO_URL: "mongodb://mongo/${MONGO_DB}"
      MAIL_URL: "${MAIL_URL}"
      REACTION_USER: '${REACTION_USER}'
      REACTION_AUTH: '${REACTION_AUTH}'
      REACTION_EMAIL: '${REACTION_EMAIL}'
      REACTION_LOG_LEVEL: '${REACTION_LOG_LEVEL}'
{{- if ne .Values.mongo_link ""}}
    external_links:
      - ${mongo_link}:mongo
    tty: true
{{- else}}
  mongo:
    command: mongod --storageEngine=wiredTiger
    restart: always
    environment:
      MONGO_SERVICE_NAME: mongo
      CATTLE_SCRIPT_DEBUG: ${debug}
    tty: true
    image: mongo:3.4
    labels:
      io.rancher.scheduler.affinity:host_label: ${host_label}
      io.rancher.container.hostname_override: container_name
    volumes:
      - mongodata:/data/db
volumes:
  mongodata:
    driver: ${VOLUME_DRIVER}
{{- end}}
