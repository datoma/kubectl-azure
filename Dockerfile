FROM alpine:latest as build
RUN apk --no-cache add coreutils make unzip curl

RUN curl -LO https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl \
    && chmod 755 kubectl
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
    && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_${arch}.tar.gz" \
    && tar zxvf krew-linux_${arch}.tar.gz \
    && chmod +x krew-linux_${arch} \
    && mv krew-linux_${arch} krew-linux

# use microsoft official image and add stuff above
FROM mcr.microsoft.com/azure-cli:2.47.0
RUN apk --no-cache add make python3 git
COPY --from=build /kubectl /usr/bin/kubectl
COPY --from=build /krew-linux /tmp/krew-linux
RUN ./tmp/krew-linux install krew \
    && rm -f /tmp/krew-linux

# TODO remove hardcoded path
ENV PATH=/root/.krew/bin:${PATH}
#ENV PATH=${HOME}/.krew/bin:${PATH}