# language: pt
Funcionalidade: Terminal de Validação
    Como operador
    Eu quero digitar a matrícula do estudante no Terminal de Validação
    Para que o estudante só entre se tiver saldo suficiente

    Contexto:
        Dado que sou um operador
        E que tenho uma catraca
        E que estou na página "Terminal de Validação"

    # Cenários positivos
    Cenário: Estudante com saldo suficiente
        Dado que existem estudantes com saldo suficiente
        Quando valido a matrícula de um estudante com saldo suficiente
        Então devo ver uma mensagem de acesso liberado
        E o saldo do estudante deve ter uma refeição a menos

    # Cenários negativos
    Cenário: Estudante sem saldo suficiente
        Dado que existem estudantes sem saldo suficiente
        Quando valido a matrícula de um estudante sem saldo suficiente
        Então devo ver uma mensagem de saldo insuficiente
        E o saldo do estudante não deve mudar

    Cenário: Matrícula não cadastrada
        Quando valido uma matrícula não cadastrada
        Então devo ver uma mensagem de matrícula não cadastrada
