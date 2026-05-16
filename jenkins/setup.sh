#!/bin/bash

echo "Starting Jenkins and Docker installation..."

# עדכון המערכת
sudo apt update -y

# התקנת Java
sudo apt install fontconfig openjdk-17-jre -y

# התקנת Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

# הפעלת Jenkins כסרוויס (systemd) - סעיף בונוס!
sudo systemctl enable jenkins
sudo systemctl start jenkins

# התקנת Docker (כדי שג'נקינס יוכל לארוז את האפליקציה)
sudo apt install docker.io -y
# הוספת המשתמש של ג'נקינס לקבוצת דוקר כדי שיוכל להריץ פקודות
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "Installation complete!"
# הצגת סיסמת האדמין הראשונית
echo "Your initial Jenkins Admin Password is:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword