# Billete

[![CI](https://github.com/Roughosing/billete/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Roughosing/billete/actions/workflows/ci.yml)
[![Ruby](https://img.shields.io/badge/Ruby-3.3.6-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.4-D30001?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)

Billete sells general admission tickets from organisers. An event's date, place, and price are fixed when it goes on sale.

## Versions

- Ruby 3.3.6 (`.ruby-version`)
- Rails 8.1.4

## CI

Pull requests and pushes to `main` run [`.github/workflows/ci.yml`](.github/workflows/ci.yml). The badge above stays green when every check passes:

- **test** — Rails test suite, then seeds
- **system-test** — system tests
- **lint** — RuboCop
- **scan_ruby** — Brakeman and Bundler audit
- **scan_js** — importmap vulnerability audit
- **Docker image** — production image build, then a boot check against Postgres

Run the same checks locally with `bin/ci`.

## Development

Billete uses PostgreSQL. Create the databases, install gems, and start the server:

```bash
bin/setup
```

`bin/setup` runs `bin/dev`, which starts the Rails server.

## Tests

```bash
bin/rails test
bin/rails test test/models/user_test.rb
bin/rails test:system
```
