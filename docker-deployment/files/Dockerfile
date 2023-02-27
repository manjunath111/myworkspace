FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    exec bash

RUN rbenv install 3.0.0 && \
    rbenv global 3.0.0

RUN gem install bundler

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install --system --jobs 4 --retry 3

COPY . /app

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8080"]
