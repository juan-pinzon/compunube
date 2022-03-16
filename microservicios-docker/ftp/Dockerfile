FROM alpine:3.15.0
ENV FTP_USER=foo \
	FTP_PASS=bar \
	GID=1000 \
	UID=1000

RUN apk add --no-cache --update \
	vsftpd==3.0.5-r1

COPY [ "/vsftpd.conf", "/etc" ]
COPY [ "/entrypoint.sh", "/" ]

CMD [ "/usr/sbin/vsftpd" ]
ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 20/tcp 21/tcp 30000-30010/tcp
HEALTHCHECK CMD netstat -lnt | grep :21 || exit 1
