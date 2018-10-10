FROM python:2.7-alpine

RUN mkdir -p /root/ansible
WORKDIR /root/ansible
VOLUME /root/ansible

COPY requirements.txt /root/

RUN apk add --no-cache --virtual .build-deps \
		gcc \
		g++ \
	&& pip install --no-cache-dir -r /root/requirements.txt \
	&& apk del .build-deps \
	&& rm -rf ~/.cache \
	&& apk add --no-cache \
		openssh-client \
		rsync \
		sshpass \
	&& ln -s /usr/local/bin/python /usr/bin/python

CMD ["ansible-playbook"]
