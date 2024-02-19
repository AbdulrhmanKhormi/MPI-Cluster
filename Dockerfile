FROM alpine:latest as base
LABEL authors="khormi"

COPY src /app
WORKDIR /app

RUN apk update \
    && apk add --no-cache openmpi openmpi-dev gcc g++ openssh sshpass python3 python3-dev py3-pip py3-setuptools py3-wheel

RUN pip3 install --upgrade --no-cache-dir --break-system-packages pip \
    && pip3 install --no-cache-dir --break-system-packages -r requirements.txt

RUN apk del openmpi-dev gcc g++ python3-dev py3-pip py3-setuptools py3-wheel

COPY ssh-key/id_rsa /root/.ssh/id_rsa
COPY ssh-key/id_rsa.pub /root/.ssh/authorized_keys

RUN chown root:root /root/.ssh/id_rsa \
    && chown root:root /root/.ssh/authorized_keys

RUN ssh-keygen -A

RUN echo "Host *" >> /root/.ssh/config \
  && echo "StrictHostKeyChecking no" >> /root/.ssh/config \
  && echo "UserKnownHostsFile=/dev/null" >> /root/.ssh/config

EXPOSE 22

CMD ["sh", "-c", "/usr/sbin/sshd -D"]
