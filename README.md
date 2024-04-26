# Orchid

![Orchid Image](orchid-img.png)

## TODO

- move structs from {service,cluster}\_config to {service,cluster}

## Components

**Dashboard**
Web interface showing current state of the system and granting imperative control

**API**
Allows the platform to be controlled by an API

**ControllerInterface**
Generic Interface for controllers - only one can be used at a time globally

**DockerController**
The default controller - should work for both Docker and Podman

**ClusterSyncer**
Cluster Configuration Service - will load config and restart dependent services when config is updated.

**ServiceSyncer**
Service Configuration Service

**Poller**
Polls the sources of both the Cluster configuration and Service configuration & posts changes to ClusterSyncer/ServiceSyncer

## Architecture

2 layers of declarative setup:

- Cluster Config
- Service Config

## Development

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
