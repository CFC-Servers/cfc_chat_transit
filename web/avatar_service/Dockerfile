FROM python:3.9.0

RUN pip install -U --upgrade pip

RUN mkdir /avatars
WORKDIR /avatar-service

COPY requirements.txt .
RUN pip install --upgrade -r ./requirements.txt

COPY . .

COPY entrypoint.sh /usr/bin/
ENTRYPOINT ["entrypoint.sh"]
