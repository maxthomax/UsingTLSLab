FROM ubuntu:14.10

MAINTAINER thomas.herlea@owasp.org

# Network services
EXPOSE 22 80 443

# Software
RUN apt-get update && apt-get install -y \
  apache2 \
  libapache2-mod-php5 \
  nano \
  openssh-server \
  supervisor \
  vim

# TODO: Necessary?
RUN mkdir -p \
  /var/lock/apache2 \
  /var/run/apache2 \
  /var/run/sshd \
  /var/log/supervisor

# Provide supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# (The distinct user credentials per container approach is temporarily
# suspended in favour of root access with shared password.)
# User management
# --disabled-login is used to enable unattended user creation, especially
#   since passwords will be managed from outside the container
#RUN adduser --gecos 'Student of "Using TLS"' --disabled-login student && adduser student sudo

# Root access with shared password
RUN echo 'root:secappdev' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Default command
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Documentation

# Built with:
# $ build_image.sh
# Follow any instructions from the script.

# Run with:
# XX=01  # XX is a two-digit integer identifying a student
# run_one.sh "${XX}"
