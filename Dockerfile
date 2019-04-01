FROM alpine:3.9

LABEL   name="CLIPS JNI Alpine"\
        version="0.0"

COPY clips-jni /tmp/clips-jni

RUN set -e;\
    adduser -Ds/bin/sh -u1000 docker;\
    chown -R docker:docker /tmp/clips-jni;\
\
    #To get package index
    apk upgrade;\
\
    #We only need these dependencies while building the CLIPS JNI library
    apk add --no-cache --virtual .build-deps\
        abuild\
        gcc;\
    adduser docker abuild;\
\
    su - docker -c'\
        set -e;\
        abuild-keygen -a;\
        cd /tmp/clips-jni;\
        abuild -r;\
    ';\
\
    cp /home/docker/.abuild/docker-*.rsa.pub /etc/apk/keys/;\
    apk del .build-deps;\
\
    apk add --no-cache /home/docker/packages/tmp/x86_64/clips-jni-6.40-r0.apk;\
    rm -rf /home/docker/.abuild /home/docker/packages /tmp/clips-jni;\
\
    mkdir /app;

USER docker

CMD [\
        "java",\
        "-Djava.library.path=/usr/share/clips-jni",\
        "-jar",\
        "/usr/share/clips-jni/CLIPSJNI.jar"\
    ]