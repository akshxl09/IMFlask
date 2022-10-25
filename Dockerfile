FROM python:3.9-alpine as base

COPY ./IMFlask/ /home/IMFlask/
WORKDIR /home/IMFlask/
COPY ./requirements/requirements.txt /home/IMFlask/requirements.txt

RUN apk update && \
    apk add --update --no-cache gcc libressl-dev \
    musl-dev libffi-dev jpeg-dev zlib-dev && \
    pip install --upgrade pip && \
    pip wheel --wheel-dir=/home/IMFlask/wheels -r requirements.txt

FROM python:3.9-alpine

COPY --from=base /home/IMFlask/ /home/IMFlask/
WORKDIR /home/IMFlask/

RUN apk update && \
    apk add --update --no-cache bash curl jpeg-dev && \
    pip install --no-index \
    --find-links=/home/IMFlask/wheels \
    -r requirements.txt && \
    rm -rf /home/IMFlask/wheels

EXPOSE 5000

CMD ["gunicorn", "-w", "2", \
    "--bind", "0.0.0.0:5000", \
    "manage:application"]