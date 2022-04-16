FROM ruby:2.7.6
RUN apt-get update -qq

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn

RUN mkdir /discoverbsd
WORKDIR /discoverbsd

ADD Gemfile Gemfile.lock /discoverbsd/

RUN bundle install

ADD package.json yarn.lock /discoverbsd/
RUN yarn

ADD . /discoverbsd/
