# Flight Search Web Application

A Flask-based flight search web application that allows users to search for the cheapest flight deals using the Amadeus API
& set trip alerts that will notify users when a flight is available at a set price. 

## Features

- Search for flights by destination and origin cities.
- Set a trip alert that notifies users when flights are available.
- Specify flight details i.e. number of passengers, travel class, travel dates etc.
- View flight results with pricing and details.
- Communication with Amadeus Flight Offers API.
- Built with Flask, Bootstrap 5, Jinja2 templates, Flask-WTF, WTForms, Flask sessions, CSRF protection.
- Integrated with AWS as Backend.

## AWS Architecture

![Architecture Diagram](flightSyte-architecture.png)

## How it Works
1) The web application can be run locally or inside Docker.
2) Users must sign up and log in to access the application’s full functionality.
3) User authentication is handled by Amazon Cognito, which issues signed JWTs after successful login.
4) The frontend communicates with the AWS backend through an Amazon API Gateway (HTTP API).
5) API Gateway validates incoming requests using a Cognito JWT authorizer, ensuring only authenticated users can access protected endpoints.
6) The AWS backend consists of multiple Lambda functions, each with a clearly defined responsibility.
7) A write Lambda stores trip alert data in DynamoDB, a read Lambda queries user alerts, and a delete Lambda removes or updates alert records.
8) The subscriber Lambda subscribes emails to an SNS Topic, enabling subscribers to receive news about the site though email.
8) Finally, a scheduled processor Lambda is triggered by an Amazon EventBridge cron rule, which queries DynamoDB for active alerts and checks for available flights.
9) The processor Lambda securely retrieves third-party API credentials and email credentials from AWS Systems Manager Parameter Store.
10) When a flight that matches a users max price criteria is found, the Lambda sends a notification email to the user using the SMTP protocol.
11) All AWS services operate with least-privilege IAM permissions following security best practices.
12) Amazon CloudWatch is used to monitor Lambda executions, API Gateway requests, and application logs.
13) Within the application, users can also use a chatbot to retrieve city names and corresponding IATA codes.
14) The chatbot is powered by Amazon Bedrock using the Amazon Nova Lite foundation model.


## Requirements

- Python 3.12 or higher (For local deployment) 
- Internet connection
- Docker Desktop (For Docker deployment) 


## Installation(Local Execution)

1. Clone the git repository:
    ```bash
    git clone <git-url>
    cd Flight-Search-Webapp
   ```

2. Install required packages:
    ```bash
    pip install -r requirements.txt
   ```

3. Execute the program and visit the IP Address shown on terminal:
    ```bash
    python main.py
    example: * Running on http://192.0.0.1:3002
   ```

## Installation(Docker Execution)

1. Install Docker Desktop on your computer

2. Open the Docker app and make sure Docker is running
 
3. Run the program:
    ```bash
    docker run -it tomdocks7/flightsyte
   ```


## Troubleshooting

**Common Issues**
- Form Validation Errors:
  - Ensure all required fields are filled
  - Check dates and passenger counts 

- No Flight Results:
  - Verify city names are correct
  - Check that dates are in the future

- Unable to search flights:
  - Make certain you are logged in  

- API Server Errors, KeyError:
  - Make sure you have internet connection
  - Try again after 5-10 minutes

**"Module not found" error?**
- Run `pip install -r requirements.txt` first

**Python not found?**
- Download Python from [python.org](https://python.org)
- Make sure to check "Add Python to PATH" during installation
- Alternative commands:
  ```bash
  python -m pip install -r requirements.txt
  or
  python3 -m pip install -r requirements.txt
  or
  py -m pip install -r requirements.txt
    ```
    ```bash
    py main.py
    ```

**Still having issues, try these:**
- Check Python version: `python --version`
- Ensure you're in the project directory
- Copy the error and paste on Google or a Gen A.I. tool.
- Open an issue on GitHub with your error message

## Disclaimer
***NB: Numerous improvements can be made to this application.*** 

***NB: This was constructed to merely display the developers capabilities in terms of software and cloud engineering knowledge and skills.***


## Project Notes
This project demonstrates:
* Designing a serverless, event-driven architecture on AWS
* Secure user authentication and authorization using Amazon Cognito (JWT-based access)
* Backend API protection and request validation via Amazon API Gateway
* DynamoDB data modeling optimized for cost-efficient querying and scheduled processing
* Scheduled background processing using Amazon EventBridge and Lambda
* Secure secret handling with AWS Parameter Store
* Least-privilege IAM policies applied across all AWS resources
* Cost-aware design decisions, including the use of on-demand billing and query-based access patterns
* Scalable measures put in place to ensure reliability of resources and failure handling capabilities implementation 
* Containerized for CI/CD purposes
* Infrastructure as Code using Terraform for centralized management, deployments and monitoring
* Observability and operational monitoring via Amazon CloudWatch
* AI-assisted user experience using Amazon Bedrock (Nova Lite)

This repository reflects a production-style separation of concerns, with a clear boundary between frontend logic, authentication, backend APIs, and asynchronous processing.