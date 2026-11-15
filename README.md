# UnB RU

Sistema do Restaurante Universitário da UnB. Projeto do Grupo 7 de Engenharia de Software (2026/2).

## Funcionalidades

- **Estudante:** cadastro, login, saldo, recarga por PIX ou cartão, extrato e exportação do extrato em PDF.
- **Operador:** login, escolha da catraca em que vai operar e desconexão.
- **Admin:** login e gestão de restaurantes e catracas.
- **Catraca:** libera a entrada do estudante pela matrícula e desconta uma refeição do saldo.
- **Cardápio:** página pública com o cardápio de cada dia da semana.

## Como rodar

Precisa de Ruby 3.4.10, Bundler e SQLite 3.

```
bundle install
bin/rails db:prepare
bin/rails server
```

O app abre em http://localhost:3000. Para usar outra porta: `bin/rails server -p 3001`.

## Como usar

Operador e admin não se cadastram pela tela. As contas são criadas pelo terminal, com matrícula de 7 dígitos
e senha de 8 caracteres ou mais:

```
bin/rails runner 'Account.create!(user: "1000000", password: "senha123", name: "Admin", role: "admin")'
bin/rails runner 'Account.create!(user: "2000000", password: "senha123", name: "Operador", role: "operator")'
```

Vale seguir esta ordem, porque o operador só escolhe catracas que o admin já criou:

1. **Admin:** entre em `/admin_session/new`. Em Gestão de Restaurantes, cadastre uma unidade e depois uma
   catraca com operação **Ativa**.
2. **Operador:** entre em `/operator_session/new`, escolha o restaurante e a catraca e confirme. O Terminal de
   Validação mostra a catraca escolhida e o botão para desconectar.
3. **Estudante:** abra a página inicial e clique em "Cadastre-se". A matrícula tem 9 dígitos: ano (00 a 26),
   semestre (10 ou 20) e mais 5 números, como `241012345`. Depois do cadastro dá para recarregar, ver o
   extrato e exportar o PDF. No cartão, qualquer número de 16 dígitos, validade futura e CVV de 3 dígitos
   passam.
4. **Catraca:** é a máquina física, então não tem tela no sistema. Para simular o estudante passando, rode no
   terminal com a matrícula dele:

   ```
   curl -X POST localhost:3000/access_control/check -d registration=241012345
   ```

   Se tiver saldo, aparece "Acesso Liberado" e a refeição (R$ 4,50) sai do saldo e entra no extrato.

Os logins de estudante, operador e admin são independentes, então dá para estar com os três abertos no mesmo
navegador. Ainda não há logout.

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
