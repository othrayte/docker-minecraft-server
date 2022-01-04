FROM openjdk:18-alpine

RUN addgroup app && adduser -S -G app app

RUN apk --no-cache add zip curl

COPY ./start.sh /

RUN mkdir /server \
    && chown -R app:app /server \
    && chmod +x /start.sh

WORKDIR /server

VOLUME /server

ENTRYPOINT ["/start.sh"]

USER app

EXPOSE 25565
