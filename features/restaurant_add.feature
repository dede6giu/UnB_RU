# language: pt
Funcionalidade: Adicionar restaurantes
    Como um administrador
    Eu quero adicionar restaurantes
    Para que empregados possam escolhê-los na aplicação de controle e estudantes possam frequentá-los

    Contexto:
        Dado que sou um admin
        E estou na página "Cadastrar Restaurante"

    # Cenários Positivos
    Cenário: Adicionar um restaurante
        Quando preencho "restaurant_name" corretamente
        E preencho "restaurant_campus" corretamente
        E clico no botão criar restaurante
        Então eu devo estar na página "Gestão de Restaurantes e Catracas"
        E eu devo ver o novo restaurante

    # Cenários Negativos
    Delineação do Cenário: Adicionar um restaurante com valores inválidos
        Quando preencho "<correct>" corretamente
        E preencho "<incorrect>" incorretamente
        E clico no botão criar restaurante
        Então devo ver uma mensagem de <message>

        Exemplos:
            | correct           | incorrect         | message                          |
            | restaurant_name   | restaurant_campus | campus do restaurante está vazio |
            | restaurant_campus | restaurant_name   | nome do restaurante está vazio   |

    Cenário: Adicionar um restaurante que já existe
        Dado que existem restaurantes
        E eu conheço um restaurante
        Quando preencho "restaurant_name" com o valor do restaurante que conheço
        E preencho "restaurant_campus" com o valor do restaurante que conheço
        E clico no botão de criar restaurante
        Então devo ver uma mensagem de restaurante existente