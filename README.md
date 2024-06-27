Node.js Application with Docker, AWS, CI/CD, and Monitoring
Project Overview
This project demonstrates how to containerize a simple Node.js application using Docker, deploy it to an AWS EC2 instance, set up a CI/CD pipeline with GitHub Actions, and implement monitoring with Prometheus and Grafana.

Prerequisites
Before you begin, ensure you have the following installed on your local machine:

Node.js and npm: Node.js
Docker: Docker
AWS CLI: AWS CLI
Elastic Beanstalk CLI: EB CLI
Step-by-Step Instructions
Step 1: Launch an EC2 Instance
Launch an EC2 Instance:

Go to the AWS Management Console.
Navigate to the EC2 Dashboard.
Click on "Launch Instance".
Choose the Amazon Linux 2 AMI.
Select the t2.micro instance type.
Configure the instance details.
Add storage (default 8 GB).
Configure the security group to allow SSH (port 22), HTTP (port 80), and custom TCP (port 3000).
Review and launch the instance.
Download the key pair and save it securely.
Connect to the EC2 Instance:

Use the key pair to connect to your instance via SSH:
ssh -i "your-key-pair.pem" ec2-user@your-ec2-instance-public-dns
Update the EC2 Instance:

Once connected, update the package index:
sudo yum update -y
Step 2: Set Up Docker on EC2
Install Docker:

Install Docker on the EC2 instance:
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
Log out and log back in for the changes to take effect.
Verify Docker Installation:

Verify that Docker is installed and running:
docker --version
docker info
Step 3: Create the Web Application
Set up the project directory:

On the EC2 instance, create a new directory for your project:
mkdir my-node-app
cd my-node-app
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
Open a web browser and navigate to http://your-ec2-instance-public-dns:3000 to see Hello, DevOps!.
Step 4: Containerize the Application with Docker
Create a Dockerfile:

In the project directory, create a file named Dockerfile and add the following content:
# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Define environment variable
ENV NODE_ENV=production

# Run server.js when the container launches
CMD ["node", "server.js"]
Build the Docker image:

Build the Docker image using the following command:
docker build -t my-node-app .
Run the Docker container:

Run the Docker container:
docker run -p 3000:3000 my-node-app
Open a web browser and navigate to http://your-ec2-instance-public-dns:3000 to see your application running inside a Docker container.
Step 5: Set Up CI/CD with GitHub Actions
Create a GitHub repository:

Go to GitHub and create a new repository for your project.
Push your project files to the GitHub repository.
Create a GitHub Actions workflow:

In your project directory, create the following directory structure: .github/workflows.
Inside the workflows directory, create a file named ci-cd.yml and add the following content:
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '14'

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test

    - name: Build Docker image
      run: docker build -t my-node-app .

    - name: Log in to Docker Hub
      run: echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin

    - name: Push Docker image to Docker Hub
      run: docker push ${{ secrets.DOCKER_USERNAME }}/my-node-app
Add Docker Hub credentials to GitHub Secrets:

Go to your GitHub repository settings, navigate to Secrets, and add the following secrets:
DOCKER_USERNAME: Your Docker Hub username
DOCKER_PASSWORD: Your Docker Hub password
Push the code to GitHub:

Commit and push your code to the main branch of your GitHub repository to trigger the CI/CD pipeline.
Step 6: Deploy to AWS Elastic Beanstalk
Install Elastic Beanstalk CLI:

Install the Elastic Beanstalk CLI:
pip install awsebcli
Initialize Elastic Beanstalk:

Initialize Elastic Beanstalk for your project:
eb init -p docker my-node-app
Follow the prompts to set up your application.
Create and deploy the application:

Create and deploy your Elastic Beanstalk environment:
eb create my-node-app-env
eb open
This will deploy your Dockerized application to AWS Elastic Beanstalk and open the application URL in your browser.
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
plaintext
Copy code
      +--------------------------+
      |      GitHub Repository   |
      +--------------------------+
                  |
                  v
      +--------------------------+
      | GitHub Actions Workflow  |
      +--------------------------+
                  |
                  v
      +--------------------------+
      |   Docker Hub Registry    |
      +--------------------------+
                  |
                  v
      +--------------------------+
      | AWS EC2 Instance (EB)    |
      +--------------------------+
3. Monitoring and Logging
plaintext
Copy code
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
By following these detailed steps, you will be able to successfully set up, containerize, deploy, and monitor your web application using AWS EC2, Docker, GitHub Actions, Prometheus, and Grafana.
