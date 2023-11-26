FROM alpine:edge

RUN adduser -D unbound -G wheel
RUN apk add --no-cache unbound drill doas munin munin-node
RUN echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

COPY init.sh /init.sh
COPY unbound.conf /etc/unbound/unbound.conf
COPY unbound_munin_ /etc/unbound/unbound_munin_
COPY plugins.conf /etc/munin/plugin-conf.d/plugins.conf
RUN mkdir -p /usr/local/etc/unbound/
RUN touch /etc/unbound/unbound.log

RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_hits
RUN chown unbound /etc/unbound
RUN chown unbound /usr/local/etc/unbound/
RUN chown unbound /etc/unbound/unbound.log

RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints

USER unbound

RUN unbound-anchor -v -a "/usr/local/etc/unbound/root.key" || logger "Please check root.key"
RUN unbound-checkconf
RUN unbound -V

EXPOSE 53/tcp
EXPOSE 53/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

ENTRYPOINT ["/init.sh"]
