FROM alpine:3.9

MAINTAINER Swetha Pujari<swetha.pn@gmail.com>

ARG JMETER_VERSION="5.2.1"
ENV JMETER_HOME /opt/jmeter
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
#ENV JMETER_PLUGIN_URL https://sg-mb-kony.s3-ap-southeast-1.amazonaws.com/CETEAM/JMETER/ext.tgz
ENV JMETER_PLUGIN_URL https://github.com/Swesmilz/PerformanceTesting/blob/master/ext.tgz
ENV JMETER_USER_PROPERTY https://github.com/Swesmilz/PerformanceTesting/blob/master/user.properties
ENV JMETER_REPORT_GEN https://github.com/Swesmilz/PerformanceTesting/blob/master/reportgenerator.properties
ENV JMETER_JMETER_PROPERTY https://github.com/Swesmilz/PerformanceTesting/blob/master/jmeter.properties
ENV JMETER_REPORT_TEMPLATE https://github.com/Swesmilz/PerformanceTesting/blob/master/report-template.tgz
ENV JMETER_ENV_SH https://github.com/Swesmilz/PerformanceTesting/blob/master/entrypoint.sh

# Install extra packages
# See https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-272703023
# Change TimeZone TODO: TZ still is not set!
ARG TZ="Europe/Amsterdam"
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& apk add --no-cache nss \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& wget ${JMETER_DOWNLOAD_URL} \
	&& tar -xzf apache-jmeter-${JMETER_VERSION}.tgz \
	&& echo extracted Jmeter zip \
	&& mkdir -p /opt/jmeter  \
	&& echo directory created \
	&& mv apache-jmeter-${JMETER_VERSION} jmeter \
	&& mv jmeter /opt \
	&& echo downloading custom libraries \
	&& curl -L --silent ${JMETER_PLUGIN_URL} >  /tmp/dependencies/ext.tgz \
	&& echo download completed \
    && tar -xzf /tmp/dependencies/ext.tgz -C /opt/jmeter/lib/ext \
	&& echo jars copied \
	&& wget ${JMETER_USER_PROPERTY} \
	&& echo Downloaded user.properties file \
	&& mv user.properties  ${JMETER_BIN} \
	&& echo user.properties copied \
	&& wget ${JMETER_REPORT_GEN} \
	&& echo Downloaded reportgenerator.properties file \
	&& mv reportgenerator.properties ${JMETER_BIN} \
	&& echo reportgenerator.properties copied \
	&& wget ${JMETER_JMETER_PROPERTY} \
	&& echo Downloaded jmeter.properties file \
	&& mv jmeter.properties ${JMETER_BIN} \
	&& echo jmeter.properties copied \
	&& rm -rf /tmp/dependencies


# TODO: plugins (later)
# && unzip -oq "/tmp/dependencies/JMeterPlugins-*.zip" -d $JMETER_HOME

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint has same signature as "jmeter" command
#COPY entrypoint.sh /

WORKDIR	${JMETER_HOME}

#ENTRYPOINT ["/entrypoint.sh"]

RUN wget ${JMETER_ENV_SH} \
	&& mkdir -p /Swetha/scripts \
	&& echo Downloaded entrypoint file \
	&& mv entrypoint.sh /Swetha/scripts \
	&& echo entrypoint file moved \
	&& chmod 777 -R /Swetha/scripts \
	&& echo chmod permissions added 
	
ENTRYPOINT ["/Swetha/scripts/entrypoint.sh"]