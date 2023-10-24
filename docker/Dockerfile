FROM amazoncorretto:17-alpine

RUN apk add R bash
RUN wget -P /usr/local/bin https://github.com/broadinstitute/picard/releases/download/3.1.0/picard.jar
COPY picard.sh /usr/local/bin/picard
