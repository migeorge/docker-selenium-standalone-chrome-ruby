# Docker Selenium Chrome Standalone /w Ruby

This project provides an environment targeted at ruby projects that would like to
use the `selenium-webdriver` gem locally.

## Running the conatiner

When you run this container be sure to mount your local `/dev/shm` to the containers.
If you don't do this `/dev/shm` will be capped to 64M by default and chrome will most
likely crash.

```
docker run --name chromeshot -v /dev/shm:/dev/shm migeorge/selenium-standalone-chrome-ruby:latest
```
