# terraform-conf

Common configuration for terraform

## Prepare terraform credentials docker container

* build terraform docker image

```sh
docker pull google/cloud-sdk
docker build -t terraform --force-rm --build-arg HTTP_PROXY=$HTTP_PROXY --build-arg HTTPS_PROXY=$HTTPS_PROXY --build-arg NO_PROXY=$NO_PROXY ./credential/gcp
```

* create service account in GCP and download credentials json file

https://console.cloud.google.com/


* prepare credentials docker container

```sh
docker run -d --restart always --name gcloud-config --net host -v $PWD:$PWD -w $PWD terraform
docker exec -it gcloud-config bash
```

```sh
# prepare var
CREDENTIALS="CREDENTIALS.JSON"
GCP_PROJECT="PROJECT-NAME-2019"
KUBERNETES_CLUSTER_NAME="KUBERNETES-CLUSTER-NAME"
KUBERNETES_ZONE="ASIA-NORTHEAST1-A"

# copy google cloud platform credentials to docker container
cp $CREDENTIALS /root/.config/gcloud/credentials.json
gcloud auth activate-service-account --key-file=/root/.config/gcloud/credentials.json
gcloud config set project $GCP_PROJECT

# if kubernetes cluster already created
gcloud container clusters get-credentials $KUBERNETES_CLUSTER_NAME --zone $KUBERNETES_ZONE

# edit /root/.kube/config cluster server URL if you can not curl with IP (behind proxy, etc...)
# ex: https://1.2.3.4 => https://1.2.3.4.xip.io
```

* (OPTIONAL) set shell command alias

```sh
alias gconfig='docker run -it --rm --volumes-from gcloud-config --net host -v /etc/ssl/certs:/etc/ssl/certs:ro -v /etc/pki:/etc/pki:ro -v $PWD:$PWD -w $PWD terraform'
alias gcloud='gconfig gcloud'
# add --insecure-skip-tls-verify after kubectl if certicate failed
alias kubectl='gconfig kubectl'
alias k8ls='kubectl get all,secret,pv,pvc,configmap --show-labels'
alias kdel='kubectl delete all,secret,pv,pvc,configmap'
alias terraform='gconfig terraform'
```

## Use/Test terraform module

* edit main.tf
* uncomment `provider "kubernetes" {}` for using kubectl native config
* uncomment testing module
* run `terraform init`
* run `terraform apply`
* see also https://www.terraform.io/docs/index.html`
