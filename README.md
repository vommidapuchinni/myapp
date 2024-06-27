Node.js Application with Docker, AWS, CI/CD, and Monitoring
Project Overview
This project demonstrates how to containerize a simple Node.js application using Docker, deploy it to an AWS EC2 instance, set up a CI/CD pipeline with jenkins, and implement monitoring with Prometheus and Grafana.

Step 1: Launch an EC2 Instance

Launch an EC2 Instance:
Go to the AWS Management Console.
Navigate to the EC2 Dashboard.
Click on "Launch Instance".
Choose the ubuntu as AMI.
Select the t2.micro instance type.
Create and Download the key pair and save it securely
Configure the instance details.
Add storage (default 8 GB).
Configure the security group choose all traffic anywhere.
Review and launch the instance.

Connect to the EC2 Instance: click on connect

Update the EC2 Instance:

Once connected, update the package index:
sudo apt update -y

Step 2: 
install docker, docker-compose, jenkins, terraform, awscli, npm, node.js, maven(if need),  

Step 3: Create the Web Application
Set up the project directory:

On the EC2 instance, create a new directory for your project:
mkdir myapp
cd myapp
Initialize a Node.js project:

Initialize a new Node.js project and install express:
npm init -y
npm install express
Create the application code:

Create a file named server.js and add the following content:
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.send('Hello, DevOps!');
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
Test the application locally:

Run the application:
node server.js
Open a web browser and navigate to http://your-ec2-instance-public-ip:3000 to see Hello, DevOps!.

Step 4: Containerize the Application with Docker
Create a Dockerfile:

In the project directory, create a file named Dockerfile and add the following content:

FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "server.js"]

Build the Docker image:

Build the Docker image using the following command:
docker build -t my-node-app .
Run the Docker container:

Run the Docker container:
docker run -p 3000:3000 my-node-app
Open a web browser and navigate to http://your-ec2-instance-public-dns:3000 to see your application running inside a Docker container.

Step 5: Set Up CI/CD pipeline with jenkins

connect to jenkins server, go to manage jenkins give AWS and docker credentials 


pipeline {
    agent any
     environment {
         DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
         AWS_CREDENTIALS = credentials('aws-credentials')
         AWS_DEFAULT_REGION = 'us-east-1'
     }
    stages {
        stage('clone') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/vommidapuchinni/myapp.git']])
            }
        }
        stage('Build') {
            steps {
                script {
                    dockerImage = docker.build("myapp")
                }
            }
        }
        stage('Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }
        stage('Login to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('Push Image') {
            steps {
                sh 'docker push chinni111/myapp:latest'
            }
        }
        stage('Deploy to AWS') {
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                    }
                }
            }
        }
        stage('Verify Deployment') { 
            steps {
                script {
                    sh 'aws ec2 describe-instances --region us-east-1'
                }
            }
        }
    }
}
      
Step 7: Set Up Monitoring and Logging

Create a docker-compose.yml file:

In your project directory, create a file named docker-compose.yml and add the following content to set up Prometheus and Grafana:
version: '3.7'

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
      
Configure Prometheus:

Create a file named prometheus.yml in your project directory and add the following content:
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['host.docker.internal:3000']
Run Docker Compose:

Start the services using Docker Compose:
docker-compose up -d

Access Grafana at http://localhost:3000 and log in with the default credentials (admin/admin).
Add Prometheus as a data source in Grafana and start creating dashboards to monitor your application.

Diagrams and Explanations
1. Application Architecture
          +-----------------------+
          |   User's Browser      |
          +-----------------------+
                      |
                      v
          +-----------------------+
          |   AWS EC2 Instance    |
          |  (Docker Container)   |
          +-----------------------+
                      |
                      v
          +-----------------------+
          |    Node.js App        |
          +-----------------------+
2. CI/CD Pipeline

      +--------------------------+
      |      jenkins pipeline    |
      +--------------------------+
                  |
                  v
      +--------------------------+
      | docker&aws credentials   |
      +--------------------------+
                  |
                  v
      +--------------------------+
      |   Docker Hub Registry    |
      +--------------------------+
                  |
                  v
      +--------------------------+
      |    AWS EC2 deploy        |
      +--------------------------+
   
3. Monitoring and Logging

      +--------------------------+
      |       Grafana            |
      +--------------------------+
                  |
                  v
      +--------------------------+
      |      Prometheus          |
      +--------------------------+
                  |
                  v
      +--------------------------+
      |   Node.js App (Metrics)  |
      +--------------------------+
Conclusion
By following these detailed steps, you will be able to successfully set up, containerize, deploy, and monitor your web application using AWS EC2, Docker, jenkins pipeline, Prometheus, and Grafana.
