# syntax=docker/dockerfile:1

FROM python:3.8-alpine
# Install dependencies
RUN apk add build-base openssl-dev libpq-dev

WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY ./app.py ./

CMD [ "python3", "app.py"]