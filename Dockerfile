

FROM aliyunfc/aliyun-fc:nodejs6.10.3

# ref: https://chromium.googlesource.com/chromium/src.git/+refs
ARG VERSION
ENV VERSION ${VERSION:-master}

LABEL maintainer="skiloop <skiloop@gmail.com>"
LABEL chromium="${VERSION}"

WORKDIR /

ADD build.sh /
ADD .gclient /build/chromium/

RUN sed -i 's/mirrors.163.com/deb.debian.org/' /etc/apt/sources.list 
RUN sh /build.sh

EXPOSE 9222

ENTRYPOINT [ \
  "/bin/headless-chromium", \
  "--disable-dev-shm-usage", \
  "--disable-gpu", \
  "--no-sandbox", \
  "--hide-scrollbars", \
  "--remote-debugging-address=0.0.0.0", \
  "--remote-debugging-port=9222" \
  ]
