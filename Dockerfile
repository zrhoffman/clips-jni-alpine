FROM alpine:3

LABEL   name="CLIPS JNI Alpine"\
        version="0.0"

COPY clips-jni /tmp/clips-jni

RUN set -o errexit;\
\
    #To get package index
    apk upgrade;\
\
    # We only need these dependencies while building the CLIPS JNI library
    apk add --no-cache --virtual .build-deps\
        abuild\
        gcc;\
\
    adduser -Ds/bin/sh -u1000 docker;\
    chown -R docker:docker /tmp/clips-jni;\
\
    # The docker user needs to be in the abuild group to use the abuild command
    adduser docker abuild;\
\
    # Build the package
    su - docker -c'\
        set -o errexit;\
        abuild-keygen -a;\
        cd /tmp/clips-jni;\
        abuild -r;\
    ';\
\
    cp /home/docker/.abuild/docker-*.rsa.pub /etc/apk/keys/;\
    apk del .build-deps;\
\
    apk add --no-cache /home/docker/packages/tmp/x86_64/clips-jni-6.40-r0.apk;\
    rm -rf /home/docker/.abuild /home/docker/packages /tmp/clips-jni;

USER docker

CMD [\
        "java",\
        "-Djava.library.path=/usr/share/clips-jni",\
        "-jar",\
        "/usr/share/clips-jni/CLIPSJNI.jar"\
    ]
