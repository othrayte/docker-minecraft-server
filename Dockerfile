FROM openjdk:8

RUN adduser --system --group app

COPY ./start.sh /

RUN mkdir /server \
    && chown -R app:app /server \
    && chmod +x /start.sh

WORKDIR /server

VOLUME /server

ENTRYPOINT ["/start.sh"]

USER app

EXPOSE 25565
