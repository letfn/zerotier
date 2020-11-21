FROM defn/zerotier-containerized:1.6.0

RUN apk add socat iptables bash

COPY service /service

ENTRYPOINT [ "/service" ]

CMD [ ]
