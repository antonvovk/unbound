FROM alpine:edge

RUN apk add --no-cache unbound drill doas munin munin-node nginx

RUN echo "*       *       *       *       *       run-parts /etc/periodic/1min" >> /etc/crontabs/root
RUN adduser -D alpine -G wheel
RUN echo 'permit nopass :wheel' > /etc/doas.d/doas.conf

COPY unbound.conf /etc/unbound/unbound.conf
COPY unbound_munin_ /etc/unbound/unbound_munin_
COPY unbound-plugin.conf /etc/munin/plugin-conf.d/unbound-plugin.conf
COPY munin.conf /etc/munin/munin.conf
COPY nginx.conf /etc/nginx/http.d/default.conf

RUN touch /var/log/crond.log
RUN touch /var/log/unbound.log
RUN mkdir -p /var/log/munin && touch /var/log/munin/munin-node.log
RUN mkdir -p /var/cache/munin/www

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
RUN chown -R unbound:unbound /var/log/unbound.log
RUN chown -R munin:munin /etc/munin
RUN chown -R munin:munin /var/log/munin
RUN chown -R munin:munin /var/lib/munin
RUN chown -R munin:munin /var/cache/munin

RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints

RUN unbound-anchor -v -a "/etc/unbound/root.key" || logger "Please check root.key"
RUN unbound-checkconf
RUN unbound -V
RUN nginx -t

USER alpine

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

COPY munin-cron.sh /etc/periodic/1min/munin-cron
COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
