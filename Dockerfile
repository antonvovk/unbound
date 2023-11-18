FROM alpine:edge

RUN adduser -D unbound -G wheel
RUN apk add --no-cache unbound drill doas
RUN echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

COPY unbound.conf /etc/unbound/unbound.conf
RUN mkdir -p /usr/local/etc/unbound/
RUN mkdir -p /var/log/unbound

RUN chown unbound /etc/unbound
RUN chown unbound /usr/local/etc/unbound/
RUN chown unbound /var/log/unbound

RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints

USER unbound

RUN unbound-anchor -v -a "/usr/local/etc/unbound/root.key" || logger "Please check root.key"
RUN unbound-checkconf
RUN unbound -V

EXPOSE 53 53/udp
EXPOSE 53 53/tcp

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

ENTRYPOINT ["doas", "unbound", "-dd"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
