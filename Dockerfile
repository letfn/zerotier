FROM defn/zerotier-containerized:1.6.4

RUN apt-get update -y && apt-get install -y socat iptables net-tools procps iputils-ping bash

COPY service /service

ENTRYPOINT [ "/service" ]

CMD [ ]
