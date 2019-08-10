# Schul-Cloud Dashboard

Check out http://smashing.github.io/smashing for more information.

![image](https://user-images.githubusercontent.com/22987140/62820727-973f1f00-bb68-11e9-9b1b-187c7314945c.png)

## Setup

You need to specify the following env variables to start this project:
(You can use a [`.env` file](https://www.npmjs.com/package/dotenv))

NAME | DESCRIPTION
--- | ---
JIRA_URL | URL to Jira ticketsystem
JIRA_USERNAME |
JIRA_PASSWORD |

## Start Project

### Using Docker

When all variables are set you can run:

1. `docker-compose up`
1. open `localhost:8080/sc`

### Native Install

You need to have ruby installed on your machine.

1. `apk update && apk add make gcc g++ tzdata nodejs`
1. `bundle`
1. `smashing start -p 3030`
1. open `localhost:3030/sc`
