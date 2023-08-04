# 第一阶段：构建Maven项目
FROM openjdk:8-jdk-alpine as builder

# 安装Maven
ENV MAVEN_VERSION 3.6.3
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

RUN wget -q -O - https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /usr/lib \
    && ln -s /usr/lib/apache-maven-${MAVEN_VERSION} $MAVEN_HOME

# Copy local code to the container image.
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build a release artifact.
RUN mvn package -DskipTests

# 第二阶段：生成最终镜像
FROM jdk-8-alpine

# 复制构建好的JAR文件到最终镜像中
COPY --from=builder /app/target/yuapi-backend-0.0.1-SNAPSHOT.jar /app/target/yuapi-backend-0.0.1-SNAPSHOT.jar

# 设置容器启动命令
CMD ["java","-jar","/app/target/yuapi-backend-0.0.1-SNAPSHOT.jar","--spring.profiles.active=prod"]