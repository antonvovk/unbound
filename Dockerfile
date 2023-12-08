FROM alpine:edge

RUN apk add --no-cache unbound drill doas

RUN adduser -D alpine -G wheel
RUN echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

COPY unbound.conf /etc/unbound/unbound.conf
COPY keys/unbound_control.key /etc/unbound/unbound_control.key
COPY keys/unbound_control.pem /etc/unbound/unbound_control.pem
COPY keys/unbound_server.key /etc/unbound/unbound_server.key
COPY keys/unbound_server.pem /etc/unbound/unbound_server.pem

RUN mkdir /var/log/unbound && touch /var/log/unbound/unbound.log

RUN chown -R unbound:unbound /etc/unbound
RUN chown -R unbound:unbound /var/log/unbound

RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints

RUN doas -u unbound unbound-anchor -v -a "/etc/unbound/root.key" || logger "Please check root.key"
RUN doas -u unbound unbound-checkconf
RUN doas -u unbound unbound -V

USER alpine

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 8953

HEALTHCHECK --interval=10s --timeout=10s --start-period=5s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
