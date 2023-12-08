FROM alpine:edge

RUN apk add --no-cache unbound drill doas

RUN adduser -D alpine -G wheel
RUN echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

COPY unbound.conf /etc/unbound/unbound.conf

RUN touch /var/log/unbound.log

RUN chown -R unbound:unbound /etc/unbound
RUN chown -R unbound:unbound /var/log/unbound.log

RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints

RUN unbound-anchor -v -a "/etc/unbound/root.key" || logger "Please check root.key"
RUN unbound-checkconf
RUN unbound -V

USER alpine

EXPOSE 53/tcp
EXPOSE 53/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
