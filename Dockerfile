FROM alpine:edge

RUN apk add --no-cache unbound drill doas munin munin-node nginx

RUN adduser -D alpine -G wheel
RUN echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

COPY init.sh /init.sh
COPY unbound.conf /etc/unbound/unbound.conf
COPY unbound.log /var/log/unbound/unbound.log
COPY unbound_munin_ /etc/unbound/unbound_munin_
COPY unbound-plugin.conf /etc/munin/plugin-conf.d/unbound-plugin.conf
COPY munin-node.log /var/log/munin/munin-node.log

RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_hits
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_queue
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_memory
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_by_type
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_by_class
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_by_opcode
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_by_rcode
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_by_flags
RUN ln -s /etc/unbound/unbound_munin_ /etc/munin/plugins/unbound_munin_histogram

RUN chown -R unbound:unbound /etc/unbound
RUN chown -R unbound:unbound /var/log/unbound
RUN chown -R munin:munin /etc/munin
RUN chown -R munin:munin /var/log/munin

RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints

RUN unbound-anchor -v -a "/etc/unbound/root.key" || logger "Please check root.key"
RUN unbound-checkconf
RUN unbound -V
# todo uncomment
#RUN nginx -t

USER alpine

EXPOSE 53/tcp
EXPOSE 53/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

ENTRYPOINT ["/init.sh"]
