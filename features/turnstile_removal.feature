# language: pt
Funcionalidade: Apagar catracas
    Como administrador
    Eu quero apagar catracas
    Para que o sistema mantenha-se atualizado

    Contexto:
        Dado que sou um admin
        E que existem restaurantes
        E que existem catracas
        E que eu conheço uma catraca
        E que eu estou na página de editar da catraca que conheço

    # Cenários Positivos
    @javascript
    Delineação do Cenário: Remover uma catraca não-operacional
        Dado que a catraca que conheço está <operation>
        Quando eu clicar no link de remover catraca, e confirmar
        Então eu não devo ver a catraca que conheço

        Exemplos:
            | operation |
            | inativa   |
            | ativa     |

    # Cenários Negativos
    @javascript
    Cenário: Desistir antes de confirmar
        Quando eu clicar no link de remover catraca, e cancelar
        E eu vou para a página de "Gestão de Restaurantes e Catracas"
        Então eu devo ver a catraca que conheço

    @javascript
    Delineação do Cenário: Catraca em operação
        Dado que a catraca que conheço está <operation>
        E que a catraca que conheço tem um operador associado a ela
        Quando eu clicar no link de remover catraca, e confirmar
        Então eu devo ver uma mensagem de catraca em operação

        Exemplos:
            | operation |
            | operando  |
            | fastpass  |