# Start with default alpine
FROM docker.io/library/alpine

# Add necessary packages
RUN apk add --no-cache shadow
RUN apk add --no-cache curl
RUN apk add --no-cache openjdk17

# Setup new user
ENV USER=carpet

RUN adduser \
    --disabled-password \
    --no-create-home \
    "$USER"

RUN mkdir /server/
RUN chown -R $USER: /server/
RUN usermod -p '*' $USER

# Entrypoint
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

USER $USER
ENTRYPOINT ["/bin/entrypoint.sh"]
