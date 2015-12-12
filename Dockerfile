FROM java:8

ENV NIFI_VERSION=0.3.0 \
        NIFI_HOME=/opt/nifi

# Picked recommended mirror from Apache for the distribution.
# Import the Apache NiFi release keys
RUN set -x \
        && curl -Lf https://dist.apache.org/repos/dist/release/nifi/KEYS -o /tmp/nifi-keys \
        && gpg --import /tmp/nifi-keys \
        && curl -Lf http://apache.mirrors.lucidnetworks.net/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz  -o /tmp/nifi-bin.tar.gz \
        && curl -Lf https://dist.apache.org/repos/dist/release/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz.asc -o /tmp/nifi-bin.tar.gz.asc \
        && curl -Lf https://dist.apache.org/repos/dist/release/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz.md5 -o /tmp/nifi-bin.tar.gz.md5 \
        && curl -Lf https://dist.apache.org/repos/dist/release/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz.sha1 -o /tmp/nifi-bin.tar.gz.sha1 \
        && gpg --verify /tmp/nifi-bin.tar.gz.asc /tmp/nifi-bin.tar.gz \
        && echo "$(cat /tmp/nifi-bin.tar.gz.md5) /tmp/nifi-bin.tar.gz" | md5sum -c - \
        && echo "$(cat /tmp/nifi-bin.tar.gz.sha1) /tmp/nifi-bin.tar.gz" | sha1sum -c - \
        && mkdir -p /opt/nifi \
        && tar -z -x -f /tmp/nifi-bin.tar.gz -C /opt/nifi --strip-components=1 \
        && rm /tmp/nifi-bin.tar.gz /tmp/nifi-bin.tar.gz.asc /tmp/nifi-bin.tar.gz.md5 /tmp/nifi-bin.tar.gz.sha1 \
        && rm /tmp/nifi-keys

# These are the volumes (in order) for the following:
# 1) user access and flow controller history
# 2) FlowFile attributes and current state in the system
# 3) content for all the FlowFiles in the system
# 4) information related to Data Provenance
# You can find more information about the system properties here - https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#system_properties
VOLUME ["$NIFI_HOME/database_repository", "$NIFI_HOME/flowfile_repository", "$NIFI_HOME/content_repository", "$NIFI_HOME/provenance_repository"]

# Open port 8081 for the HTTP listen
WORKDIR $NIFI_HOME
EXPOSE 8080 8081
ENTRYPOINT ["bin/nifi.sh"]
CMD ["run"]
