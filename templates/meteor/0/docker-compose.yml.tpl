version: '2'
services:
  meteor:
    image: "${METEOR_IMAGE}"
    restart: always
    labels:
      io.rancher.scheduler.affinity:host_label: ${host_label}
      traefik.enable: 'true'
      traefik.alias: '${METEOR_HOST}'
      traefik.domain: '${METEOR_DOMAIN}'
      traefik.acme: 'true'
      traefik.port: '3000'
    environment:
      ROOT_URL: "http://${METEOR_HOST}.${METEOR_DOMAIN}"
      MONGO_URL: "mongodb://mongo/${MONGO_DB}"
      MAIL_URL: "${MAIL_URL}"
      METEOR_USER: '${METEOR_USER}'
      METEOR_AUTH: '${METEOR_AUTH}'
      METEOR_EMAIL: '${METEOR_EMAIL}'
      METEOR_LOG_LEVEL: '${METEOR_LOG_LEVEL}'
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
