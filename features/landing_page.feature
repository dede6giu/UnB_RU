# language: pt
Funcionalidade: Página inicial
    Como alguém que visita o site
    Eu quero uma página inicial com o cardápio da próxima refeição e uma entrada para cada perfil
    Para conferir a comida e chegar ao login certo

    Contexto:
        Dado que estou na página "Página Inicial"

    # Cenários positivos
    Cenário: Ver o cardápio da refeição atual
        Dado que é segunda-feira na hora do almoço
        Então devo ver o cardápio do almoço de segunda-feira

    Cenário: Ir para o cardápio completo
        Quando clico no botão de cardápio completo
        Então devo estar na página "Cardápio"

    Esquema do Cenário: Ir para o login de cada perfil
        Quando clico no botão de <perfil>
        Então devo estar na página "<página>"

        Exemplos:
            | perfil                | página                    |
            | login do estudante    | Autenticação do Estudante |
            | cadastro do estudante | Cadastro Estudantil       |
            | login do operador     | Autenticação do Operador  |
            | login do admin        | Autenticação de Admin     |

    # Cenários negativos
    Cenário: Fora do horário das refeições mostra a próxima
        Dado que é segunda-feira depois do jantar
        Então devo ver o cardápio do café da manhã de terça-feira
