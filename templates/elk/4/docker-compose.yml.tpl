version: '2'
services:
    kibana:
      restart: always
      tty: true
      image: docker.elastic.co/kibana/kibana:5.5.0
      stdin_open: true
      environment:
        ELASTICSEARCH_URL: "http://elasticsearch:9200"
      labels:
        io.rancher.container.hostname_override: container_name
        traefik.enable: true
        traefik.alias: ${KIBANA_HOST}
        traefik.domain: ${KIBANA_DOMAIN}
        traefik.acme: true
        traefik.port: 5601
    es-master:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-storage
            {{- if eq .Values.UPDATE_SYSCTL "true" -}}
                ,es-sysctl
            {{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch:${es_tag}
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "ES_JAVA_OPTS=-Xms${master_heap_size} -Xmx${master_heap_size}"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "discovery.zen.minimum_master_nodes=${minimum_master_nodes}"
            - "node.master=true"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${master_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-storage

    es-data:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-storage
            {{- if eq .Values.UPDATE_SYSCTL "true" -}}
                ,es-sysctl
            {{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch:${es_tag}
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${data_heap_size} -Xmx${data_heap_size}"
            - "node.master=false"
            - "node.data=true"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${data_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-storage
        depends_on:
            - es-master

    elasticsearch:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-storage
            {{- if eq .Values.UPDATE_SYSCTL "true" -}}
                ,es-sysctl
            {{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch:${es_tag}
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=false"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${client_heap_size} -Xmx${client_heap_size}"
            - "node.master=false"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${client_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-storage
        depends_on:
            - es-master

    es-storage:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-volume:0.0.2-1
        environment:
            - SERVICE_UID=1000
            - SERVICE_GID=1000
            - SERVICE_VOLUME=/usr/share/elasticsearch/data
        volumes:
            - es-storage-volume:/usr/share/elasticsearch/data

    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    es-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    {{- end}}

    octossh:
      image: joshuacox/octossh
      environment:
        KEY_URL: ${KEY_URL}
      ports:
      - "${SSH_PORT}:22"
      labels:
        io.rancher.container.hostname_override: container_name
        io.rancher.scheduler.affinity:host_label: ${host_label}

    logstash-indexer-config:
      restart: always
      image: rancher/logstash-config:v0.2.0
      labels:
        io.rancher.container.hostname_override: container_name
    redis:
      restart: always
      tty: true
      image: redis:3.2.6-alpine
      stdin_open: true
      labels:
        io.rancher.container.hostname_override: container_name
    logstash-indexer:
      restart: always
      tty: true
      volumes_from:
      - logstash-indexer-config
      command:
      - logstash
      - -f
      - /etc/logstash
      image: logstash:5.1.1-alpine
      stdin_open: true
      labels:
        io.rancher.sidekicks: logstash-indexer-config
        io.rancher.container.hostname_override: container_name
    logstash-collector-config:
      restart: always
      image: rancher/logstash-config:v0.2.0
      labels:
        io.rancher.container.hostname_override: container_name
    logstash-collector:
      restart: always
      tty: true
      ports:
      - "5000/udp"
      - "6000/tcp"
      volumes_from:
      - logstash-collector-config
      command:
      - logstash
      - -f
      - /etc/logstash
      image: logstash:5.1.1-alpine
      stdin_open: true
      labels:
        io.rancher.sidekicks: logstash-collector-config
        io.rancher.container.hostname_override: container_name

volumes:
  es-storage-volume:
    driver: ${VOLUME_DRIVER}
    per_container: true
