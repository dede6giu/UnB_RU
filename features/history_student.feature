# language: pt
Funcionalidade: Ver o Extrato e Histórico de Refeições
    Como estudante
    Eu quero ver meus gastos e o histórico das minhas refeições

    Contexto:
        Dado que sou um estudante
        E que estou na página "Extrato e Histórico de Refeições"

    # Cenários positivos
    Cenário: Estudante com lançamentos
        Dado que tenho lançamentos no extrato
        Então devo ver o lançamento mais novo primeiro

    # Cenários negativos
    Cenário: Estudante ainda sem lançamentos
        # Dado que não tenho lançamentos
        Então devo ver uma mensagem de extrato vazio
