FROM spikhalskiy/zerotier-containerized:1.4.6

RUN apk add socat

COPY service /service

ENTRYPOINT [ "/service" ]

CMD [ ]
