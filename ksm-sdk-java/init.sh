GRADLE_VERSION=6.5.1

wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp
unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip
rm -f /tmp/gradle-${GRADLE_VERSION}-bin.zip
echo "GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}" >> ~/.bashrc
echo "PATH=/opt/gradle/gradle-${GRADLE_VERSION}/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

apt-get -y update
apt -y install openjdk-11-jdk haveged
