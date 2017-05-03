# Portfolio CMS
This is a vapor web app that I built to demonstrate some projects I've worked on.

## Demo
[marymartinez.tech](https://marymartinez.tech)

## Main feautures

* Admin panel to manage projects, tags, links, media.
* User authentication (only one admin can be created through interface)
* User sessions to remain logged in.
* Footer to include means of contact
* Distinctive navbars for appropriate places in the app. e.g. Admin (logged in vs. logged out) and Public facing.

#### Note: This app uses [sachinchoolur's lightgallery.js](https://github.com/sachinchoolur/lightgallery.js) and requires a license.

## Installation

Make sure you've got Swift 3, [Vapor](https://github.com/vapor/vapor), and any dependencies installed first. 

You can install this by cloning the repo.

`git clone https://github.com/mlmc03/portfolio-v2/`

### PostgreSQL

You'll need to set up your own PostgreSQL configuration file here `Config/secrets/postgresql.json`.

```
{
    "host": "127.0.0.1",
    "user": "postgres",
    "password": "",
    "database": "test",
    "port": 5432
}
```

For help with this, refer to the Vapor [PostgreSQL-Provider](https://github.com/vapor-community/postgresql-provider) page.

### Nginx Server

I used Nginx in my Ubuntu setup. Here's a great [tutorial by Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04) to help you get started.

### Supervisor

This will run the process on the server so that your site can go "live". [Vapor has some documentation](https://vapor.github.io/documentation/deploy/supervisor.html) on this as well.

## Compatibility

This project has been tested on macOS and Ubuntu.
