FROM elixir:1.6

WORKDIR /app

COPY . .

RUN rm -rf ./_build/ && \
    mix do local.hex --force, local.rebar --force && \
    MIX_ENV=staging mix compile.protocols && \
    MIX_ENV=prod  mix compile.protocols

CMD echo "Checking system variables..." && \
    scripts/show-vars.sh \
      "MIX_ENV" \
      "ERLANG_OTP_APPLICATION" \
      "ERLANG_HOST" \
      "ERLANG_MIN_PORT" \
      "ERLANG_MAX_PORT" \
      "ERLANG_MAX_PROCESSES" \
      "ERLANG_COOKIE" && \
    scripts/check-vars.sh "in system" \
      "MIX_ENV" \
      "ERLANG_OTP_APPLICATION" \
      "ERLANG_HOST" \
      "ERLANG_MIN_PORT" \
      "ERLANG_MAX_PORT" \
      "ERLANG_MAX_PROCESSES" \
      "ERLANG_COOKIE" && \
    echo "Running app..." && \
    elixir \
      --name "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \
      --cookie "$ERLANG_COOKIE" \
      --erl "+K true +A 32 +P $ERLANG_MAX_PROCESSES" \
      --erl "-kernel inet_dist_listen_min $ERLANG_MIN_PORT" \
      --erl "-kernel inet_dist_listen_max $ERLANG_MAX_PORT" \
      -pa "_build/$MIX_ENV/consolidated/" \
      -S mix run \
      --no-halt
