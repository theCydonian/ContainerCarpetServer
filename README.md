# ContainerCarpetServer
Containerized Servers for Technical Minecraft

## Introduction

This project aims to provide a system for running a Fabric Minecraft 
server(with Carpet!) inside of a Podman(or Docker) container for improved 
security.

The project is developed for and tested with Podman, but Docker likely works 
near identically. OpenRC currently the only supported init system, but 
it should not be too hard to write a service script for SystemD. Feel free to 
submit a PR if you write a script for SystemD to use with this project.

This branch aims to support the latest version of Minecraft, but it should not 
be hard to make this work with older versions as well. Feel free to submit a 
PR to support other versions.

Current Minecraft Version: 1.19.0

## Installation

### Prerequisites

* Linux
* Podman

### System Setup

1. Create a non-permissioned user.
`useradd -m `
2. Create a folder

### Installation

### OpenRC Setup

## Backups

## Debugging

## Useful Links

## Projects Used
