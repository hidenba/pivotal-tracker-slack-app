FROM amazon/aws-lambda-ruby

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local path 'vendor/bundle' && \
bundle config set without test && \
bundle install

COPY . ./

CMD ["src/app.lambda_handler"]
