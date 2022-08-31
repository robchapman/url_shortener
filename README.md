# README

A simple web application that will take a URL string and return a shortened conversion that will redirect to the original.

## Setup

The repo includes a dockerfile, tested with docker version `20.10.14`, that will build a ruby container and run the rails on `http://localhost:3000/`.

First build:
```
docker build -t url_shortener .
```

Then run:
```
docker run -p 3000:3000 url_shortener
```

When you navigate to `http://localhost:3000/`, you should see the url shortening form.

Thanks!