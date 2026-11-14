# UnB RU

Sistema do Restaurante Universitário da UnB. Projeto do Grupo 7 de Engenharia de Software (2026/2).

## Funcionalidades

- **Estudante:** cadastro, login, saldo, recarga por PIX ou cartão, extrato e exportação do extrato em PDF.
- **Operador:** login, escolha da catraca em que vai operar e desconexão.
- **Admin:** login e gestão de restaurantes e catracas.
- **Catraca:** `POST /access_control/check` com a matrícula libera a entrada e debita uma refeição.

## Como rodar

Precisa de Ruby 3.4.10, Bundler e SQLite 3.

```
bundle install
bin/rails db:prepare
bin/rails server
```

Abra http://localhost:3000, que leva ao login do estudante (o cadastro está na mesma tela). Operador e
admin entram por `/operator_session/new` e `/admin_session/new`; as contas deles são criadas pelo terminal:

```
bin/rails runner 'Account.create!(user: "1000000", password: "senha123", name: "Admin", role: "admin")'
bin/rails runner 'Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")'
```

## Testes

```
bin/rails db:test:prepare
bundle exec rspec
bundle exec cucumber --no-strict
bin/rubocop
```

Os mesmos comandos rodam no CI em todo pull request.

## Documentação

Features, responsáveis e regras de negócio na [wiki](https://github.com/dede6giu/UnB_RU/wiki).
