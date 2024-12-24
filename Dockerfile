FROM quay.io/jupyter/scipy-notebook:2024-11-19
USER root

RUN pip install pyspark
RUN pip install psycopg2-binary
RUN sudo apt update
RUN sudo apt install -y python3-psycopg2
# Устанавливаем Java
RUN apt update && apt install -y openjdk-11-jdk

# Настраиваем JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH