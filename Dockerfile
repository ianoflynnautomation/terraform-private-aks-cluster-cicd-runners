ARG RUNNER_VERSION="2.328.0"
FROM ghcr.io/actions/actions-runner:${RUNNER_VERSION}

ARG TERRAFORM_VERSION="1.9.1-1"
ARG KUBECTL_VERSION="1.30.2-1.1"

USER root

RUN apt-get update \
    && apt-get install -y curl gpg lsb-release apt-transport-https

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
    
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
    
RUN apt-get update \
    && apt-get install -y terraform=${TERRAFORM_VERSION} kubectl=${KUBECTL_VERSION} \
    && rm -rf /var/lib/apt/lists/*

USER runner