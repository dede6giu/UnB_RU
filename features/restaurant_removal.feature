# language: pt
Funcionalidade: Apagar restaurantes
    Como um administrador
    Eu quero apagar restaurantes
    Para remover restaurantes inexistentes do sistema

    Contexto:
        Dado que sou um admin
        E que existe um restaurante
        E que eu conheço um restaurante
        E que existem catracas que são não-operacionais
        E que eu estou na página de edição do restaurante que conheço

    # Cenários Positivos
    @javascript
    Cenário: Remover restaurante
        Dado que o restaurante que conheço tem uma catraca em estado não-operacional
        Quando eu clicar no link de remover restaurante, e confirmar
        Então eu não devo ver o restaurante que conheço
#        E não devo ver catracas do restaurante que conheço

    # Cenários Negativos
    @javascript
    Cenário: Desistir antes de confirmar
        Quando eu clicar no link de remover restaurante, e cancelar
        E eu vou para a página de "Gestão de Restaurantes e Catracas"
        Então eu devo ver o restaurante que conheço

    @javascript
    Cenário: Restaurant with a turnstile in operation
        Dado que o restaurante que conheço tem uma catraca em estado operacional
        Quando eu clicar no link de remover restaurante, e confirmar
        Então eu devo ver uma mensagem de catracas em operação
        E eu devo ver o restaurante que conheço