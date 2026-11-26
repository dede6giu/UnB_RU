# language: pt
Funcionalidade: Adicionar catracas
    Como um administrador
    Eu quero adicionar catracas a restaurantes
    Para que elas possam ser controladas por operadores e estudantes possam vê-las no sistema

    Contexto:
        Dado que sou um admin
        E que existem restaurantes
        E que existem catracas
        E estou na página "Cadastrar Catraca"

    # Cenário Positivo
    Cenário: Adicionar catraca num restaurante
        Quando eu preencho "turnstile_name" evitando todas as catracas
        E do dropdown "turnstile_operation" eu escolho qualquer coisa
        E do dropdown "turnstile_restaurant_id" eu escolho qualquer coisa
        E clico no botão de criar catraca
        Então eu devo estar na página "Gestão de Restaurantes e Catracas"
        E devo ver o novo "turnstile_name"

    # Cenário Negativo
    Cenário: Nome inválido
        Quando eu preencho "turnstile_name" incorretamente
        E do dropdown "turnstile_operation" eu escolho qualquer coisa
        E do dropdown "turnstile_restaurant_id" eu escolho qualquer coisa
        E clico no botão de criar catraca
        Então eu devo ver uma mensagem do nome da catraca está vazio

    Cenário: Catraca já existente
        Dado que eu conheço uma catraca
        Quando eu preencho "turnstile_name" com o valor da catraca que conheço
        E do dropdown "turnstile_restaurant_id" eu escolho o valor da catraca que conheço
        E do dropdown "turnstile_operation" eu escolho qualquer coisa
        E clico no botão de criar catraca
        Então eu devo ver uma mensagem de catraca existente