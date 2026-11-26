# language: pt
Funcionalidade: Editar restaurantes
    Como um administrador
    Eu quero editar restaurantes
    Para manter informações atualizadas

    Contexto:
        Dado que sou um admin
        E que existem restaurantes
        E que eu conheço um restaurante
        E que eu estou na página de edição do restaurante que conheço

    # Cenários Positivos
    Delineação do Cenário: Renomear o nome ou campus de um restaurante
        Quando preencho "<i_know_id>" evitando todos os restaurantes
        E preencho "<knownt_id>" corretamente
        E eu clico no botão de salvar restaurante
        Então eu devo estar na página de "Gestão de Restaurantes e Catracas"
        E devo ver o novo "<i_know_id>"
#        E operators should see the restaurant's new "<i_know_id>" on the "Configuração de Ponto" page

        Exemplos:
            | i_know_id         | knownt_id         |
            | restaurant_name   | restaurant_campus |
            | restaurant_campus | restaurant_name   |

    # Cenários Negativos
    Delineação do Cenário: Valores inválidos
        Quando preencho "<correct_id>" corretamente
        E preencho "<incorrect_id>" incorretamente
        E eu clico no botão de salvar restaurante
        Então devo ver uma mensagem de <message>

        Exemplos:
            | correct_id        | incorrect_id      | message                          |
            | restaurant_name   | restaurant_campus | campus do restaurante está vazio |
            | restaurant_campus | restaurant_name   | nome do restaurante está vazio   |

    Cenário: Renomear um restaurante para outro já existente
        Dado que eu aprendo outro restaurante
        Quando preencho "restaurant_name" com o valor de outro restaurante
        E preencho "restaurant_campus" com o valor de outro restaurante
        E eu clico no botão de salvar restaurante
        Então devo ver uma mensagem de restaurante existente