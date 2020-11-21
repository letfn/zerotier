FROM defn/zerotier-containerized:1.6.0

RUN apt-get update -y && apt-get install -y socat iptables net-tools procps bash

COPY service /service

ENTRYPOINT [ "/service" ]

CMD [ ]
