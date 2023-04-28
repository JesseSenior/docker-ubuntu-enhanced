ARG version=latest
FROM ubuntu:$version

LABEL "container.parent-name"="ubuntu-enhanced"

RUN apt update \
    && apt install -y tzdata curl; \
    apt clean;

# sshd
RUN mkdir /run/sshd; \
    apt install -y openssh-server; \
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    apt clean; \
    mkdir /root/.ssh;

COPY --chmod=700 base/entry_point.sh /usr/local/bin/
COPY --chmod=700 base/utilities.sh /usr/local/bin/
RUN echo "source /usr/local/bin/utilities.sh" >>/root/.bashrc

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]