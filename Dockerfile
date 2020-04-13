FROM spikhalskiy/zerotier-containerized:1.4.6

RUN apk add socat iptables bash

COPY service /service

ENTRYPOINT [ "/service" ]

CMD [ ]
