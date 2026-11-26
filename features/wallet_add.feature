# language: pt
Funcionalidade: Recarregar a carteira
    Como estudante
    Eu quero recarregar minha carteira por PIX ou cartão de crédito

    Contexto:
        Dado que sou um estudante
        E que tenho saldo
        E que estou na página "Recarga de Saldo"

    # Cenários positivos
    Cenário: Recarga por PIX
        Quando escolho a opção de recarga PIX
        E preencho "credit-amount" corretamente
        E clico no botão de confirmar transação
        Então devo estar na página "Recarga de Saldo"
        E devo ver uma mensagem de recarga realizada
        E devo ver meu saldo aumentado com o valor da recarga
        E devo ver a nova recarga por PIX no extrato

    Cenário: Recarga por cartão de crédito
        Quando escolho a opção de recarga cartão de crédito
        E preencho "card-number" corretamente
        E preencho "card-expire" corretamente
        E preencho "card-secure" corretamente
        E preencho "credit-amount" corretamente
        E clico no botão de confirmar transação
        Então devo estar na página "Recarga de Saldo"
        E devo ver uma mensagem de recarga realizada
        E devo ver meu saldo aumentado com o valor da recarga
        E devo ver a nova recarga por cartão de crédito no extrato

    # Cenários negativos
    Esquema do Cenário: Quantidade de recarga inválida
        Quando escolho a opção de recarga <forma>
        E preencho "credit-amount" incorretamente
        E clico no botão de confirmar transação
        Então devo estar na página "Recarga de Saldo"
        E devo ver uma mensagem de quantidade inválida
        E devo ver meu saldo sem alteração

        Exemplos:
            | forma             |
            | PIX               |
            | cartão de crédito |

    Esquema do Cenário: Dados do cartão de crédito inválidos
        Quando escolho a opção de recarga cartão de crédito
        E preencho "<correto1>" corretamente
        E preencho "<correto2>" corretamente
        E preencho "<correto3>" corretamente
        E preencho "<incorreto>" incorretamente
        E clico no botão de confirmar transação
        Então devo estar na página "Recarga de Saldo"
        E devo ver uma mensagem de <mensagem>
        E devo ver meu saldo sem alteração

        Exemplos:
        | correto1    | correto2    | correto3      | incorreto     | mensagem                  |
        | card-number | card-expire | card-secure   | credit-amount | quantidade inválida       |
        | card-expire | card-secure | credit-amount | card-number   | dados do cartão inválidos |
        | card-secure | card-number | credit-amount | card-expire   | dados do cartão inválidos |
        | card-number | card-expire | credit-amount | card-secure   | dados do cartão inválidos |
