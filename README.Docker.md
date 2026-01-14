# Flight Search Web Application (Docker)

A Flask-based flight search web application that allows users to search for the cheapest flight deals using the Amadeus API
& set trip alerts that will notify users when a flight is available at a set price. 

## Getting Started

These instructions will cover usage information and for the docker container 

### Prerequisities


In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Container Parameters

```shell
  docker run -it tomdocks7/flightsyte -p 5000:5000
```

#### Environment Variables

* N/A
#### Volumes

* N/A

#### Useful File Locations

* N/A

## Built With

* Python v.3.14
* Terraform
* AWS Cloud Services(Backend) ***See Terraform files for resource configurations***
  - AWS API Gateway
  - Amazon Cognito
  - AWS Lambda Functions
  - Amazon Bedrock
  - AWS DynamoDB
  - Amazon Eventbridge
  - Amazon SNS

## Find Us

* [GitHub](https://github.com/your/repository)

## Contributing

***Tom Dev***

## Versioning

For the versions available, see the 
[tags on the repository](https://github.com/your/repository/tags). 

## Authors

***Tom Dev***

## License

N/A

## Acknowledgments
Powered by the AWS Cloud.
