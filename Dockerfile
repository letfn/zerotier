FROM spikhalskiy/zerotier-containerized:1.4.6

COPY service /service

ENTRYPOINT [ "/service" ]

CMD [ ]
