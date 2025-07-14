
# GenAI Setup Guide

This document provides a step-by-step procedure to deploy and configure the GenAI service using Docker Compose on a Linux machine, and integrate it with Creatio.

---

## Table of Contents

1. [Install Docker](#install-docker)  
2. [Install Docker-Compose](#install-docker-compose)  
3. [Set Up Container Variables](#set-up-container-variables)  
4. [Run GenAI Service Containers](#run-genai-service-containers)  
5. [Configure GenAI Functionality in Creatio](#configure-genai-functionality-in-creatio)  
6. [Notes](#notes)

---

## Install Docker

Install Docker on a physical or virtual machine running Linux OS to deploy the GenAI components.

Refer to the official Docker installation documentation for Linux (Debian-based distributions):  
https://docs.docker.com/install/linux/docker-ce/debian/

Verify Docker installation by running the following command:

```bash
docker --version
```

---

## Install Docker-Compose

1. Install Docker-Compose on your Linux machine.

Refer to the official Docker-Compose installation guide:  
https://docs.docker.com/compose/install/

Verify Docker-Compose installation by running:

```bash
docker-compose --version
```

---

## Download docker compose files

1. Download and unpack the archive with the setup files from the repository:  
   [GenAI Docker-Compose Setup](https://github.com/Advance-Technologies-Foundation/genai-deployment/archive/refs/heads/main.zip)

2. Go to the docker-compose folder

---

## Set Up Container Variables

Configure the GenAI service containers by setting environment variables in the `.env` file located in the deployment folder. Edit this file to provide the required parameters.

### API Authentication Parameters

Provide parameters depending on the Large Language Model (LLM) service you are using:

#### For OpenAI LLM Model

| Variable                     | Description                                               |
|------------------------------|-----------------------------------------------------------|
| `OPENAI_API_KEY`              | Your OpenAI API key to authenticate API requests.         |
| `OPENAI_API_KEY_TEXT_EMBEDDING` | *(Optional)* Separate key for OpenAI text embedding service if different from main key. |

#### For Azure OpenAI LLM Model

| Variable                     | Description                                               |
|------------------------------|-----------------------------------------------------------|
| `AZURE_API_KEY`               | Azure API key (subscription key) for authentication.      |
| `AZURE_API_TEXT_EMBEDDING`   | *(Optional)* Separate API key or token for Azure text embedding service. |
| `AZURE_DEPLOYMENTID`          | Deployment ID or name of the Azure OpenAI model to use.   |
| `AZURE_RESOURCENAME`          | Name of your Azure OpenAI resource instance for endpoint construction. |
| `AZURE_API_BASE`          | The base URL of your Azure OpenAI endpoint. This is typically in the format https://<your-resource-name>.openai.azure.com. It's used to construct full API request URLs. |
| `AZURE_API_VERSION`          | The version of the Azure OpenAI API to use. For example: 2023-07-01-preview. This must match a supported version by Azure and may change over time as the API evolves. |

### Default Models

Set the default models used by GenAI:

| Variable                     | Description                                               |
|------------------------------|-----------------------------------------------------------|
| `GenAI__DefaultModel`         | Identifier or name of the default language generation model (for text completion or chat). |
| `GenAI__EmbeddingsModel`      | Identifier or name of the default text embeddings model.  |

---

## Run GenAI Service Containers

1. Open a terminal and navigate to the docker-compose folder.

2. Run the following command to start the GenAI service containers in detached mode:

```bash
docker-compose up -d
```

---

## Configure GenAI Functionality in Creatio

1. Open Creatio and go to **System Settings**.

2. Locate the setting named **Account enrichment service url**.

3. Set its value to:

```
http://[your_server_ip_address]:5006
```

Replace `[your_server_ip_address]` with the actual IP address or hostname of the server where the GenAI Docker containers are running.

## Notes

- This deployment uses **Docker Compose** for orchestration.  
- Ensure that the firewall allows inbound traffic on port **5006** for Creatio to communicate with the GenAI service.  
- Keep the `.env` file secure, as it contains sensitive API keys.  

---

If you have any questions or require assistance, please refer to the project repository or contact support.
