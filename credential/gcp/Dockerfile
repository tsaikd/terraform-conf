FROM google/cloud-sdk
ARG TERRAFORM_VERSION="0.11.11"
VOLUME ["/root/.config", "/root/.kube"]
ENV HTTP_PROXY $HTTP_PROXY
ENV http_proxy $HTTP_PROXY
ENV HTTPS_PROXY $HTTPS_PROXY
ENV https_proxy $HTTPS_PROXY
ENV NO_PROXY $NO_PROXY
ENV no_proxy $NO_PROXY
ENV GOOGLE_APPLICATION_CREDENTIALS /root/.config/gcloud/credentials.json
RUN apt-get update ; \
    apt-get install -qy vim unzip && \
    apt-get clean
RUN curl https://github.com/ahmetb/kubectx/raw/master/kubens -L --output /usr/local/bin/kubens && \
    chmod +x /usr/local/bin/kubens
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -L --output /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip
RUN mkdir -p /root/config/gcloud
CMD sleep 86400
