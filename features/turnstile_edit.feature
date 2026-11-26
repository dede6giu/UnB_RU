# language: pt
Funcionalidade: Editar catracas
    Como um administrador
    Eu quero editar catracas
    Para manter informações atualizadas

    Contexto:
        Dado que sou um admin
        E que existem restaurantes
        E que existem catracas
        E que eu conheço uma catraca
        E que eu estou na página de editar da catraca que conheço

    # Cenários Positivos
    Delineação do Cenário: Alterar entre inativa e ativa
        Dado que a catraca que conheço está <now>
        E do dropdown "turnstile_operation" eu escolho "<new_str>"
        E eu preencho "turnstile_name" com o valor da catraca que conheço
        E do dropdown "turnstile_restaurant_id" eu escolho o valor da catraca que conheço
        E eu clico no botão salvar catraca
        Então a catraca que conheço deve estar <new_mode>

        Exemplos:
            | now     | new_mode | new_str |
            | ativa   | inativa  | Inativa |
            | inativa | ativa    | Ativa   |

    Cenário: Renomear catraca
        Quando eu preencho "turnstile_name" evitando todas as catracas
        E eu preencho "turnstile_name" com o valor da catraca que conheço
        E do dropdown "turnstile_restaurant_id" eu escolho o valor da catraca que conheço
        E eu clico no botão salvar catraca
        Então eu devo ver o novo "turnstile_name"

    # Cenários Negativos
    Cenário: Renomear catraca para uma catraca existente
        Dado que eu aprendo outra catraca
        Quando eu preencho "turnstile_name" com o valor da outra catraca
        E do dropdown "turnstile_restaurant_id" eu escolho o valor da outra catraca
        E do dropdown "turnstile_operation" eu escolho qualquer coisa
        E eu clico no botão salvar catraca
        Então eu devo ver uma mensagem de catraca existente

    Cenário: Renomear catraca com nome inválido
        Quando eu preencho "turnstile_name" incorretamente
        E do dropdown "turnstile_operation" eu escolho qualquer coisa
        E do dropdown "turnstile_restaurant_id" eu escolho qualquer coisa
        E eu clico no botão salvar catraca
        Então eu devo ver uma mensagem de nome da catraca está vazio

    Delineação do Cenário: Desativar uma catraca em operação
        Dado que a catraca que conheço está <curr_mode>
        E que a catraca que conheço tem um operador associado a ela
        Quando do dropdown "turnstile_operation" eu escolho "<new_str>"
        E eu preencho "turnstile_name" com o valor da catraca que conheço
        E do dropdown "turnstile_restaurant_id" eu escolho o valor da catraca que conheço
        E eu clico no botão salvar catraca
        Então eu devo ver uma mensagem de catraca em operação
        E a catraca que conheço deve estar <curr_mode>

        Exemplos:
            | curr_mode | new_str |
            | operando  | Ativa   |
            | operando  | Inativa |
            | fastpass  | Ativa   |
            | fastpass  | Inativa |