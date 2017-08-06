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
      MONGO_URL: "mongodb://${MONGO_HOST}/${MONGO_DB}"
      REACTION_USER: '${REACTION_USER}'
      REACTION_AUTH: '${REACTION_AUTH}'
      REACTION_EMAIL: '${REACTION_EMAIL}'
      REACTION_LOG_LEVEL: '${REACTION_LOG_LEVEL}'
