# language: pt
Funcionalidade: Exportar o Extrato e Histórico de Refeições
    Como estudante
    Eu quero exportar meu Extrato e Histórico de Refeições em PDF
    Para controlar melhor minhas finanças

    Contexto:
        Dado que sou um estudante
        E que estou na página "Extrato e Histórico de Refeições"

    # Cenários positivos
    Cenário: Baixar meus lançamentos
        Dado que tenho lançamentos no extrato
        Quando clico no botão de exportar PDF
        Então um PDF com o meu extrato é baixado

    Esquema do Cenário: Filtrar por tipo de lançamento
        Dado que tenho lançamentos no extrato
        Quando filtro pelo tipo de lançamento "<tipo>"
        E clico no botão de exportar PDF
        Então um PDF com o meu extrato é baixado
        E o PDF só deve ter lançamentos do tipo "<tipo>"

        Exemplos:
        | tipo      |
        | Recargas  |
        | Refeições |

        Exemplos:
        | tipo          |
        | Café da manhã |
        | Almoço        |
        | Jantar        |

    # Cenários negativos
    Cenário: Tentar exportar sem lançamentos
        Quando clico no botão de exportar PDF
        Então devo ver uma mensagem de extrato vazio
