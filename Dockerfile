FROM elixir:1.11

RUN apt-get update

RUN apt-get install -y inotify-tools

RUN apt-get install -y postgresql-client

RUN mkdir ./app
COPY . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get

CMD /app/entrypoint.sh
