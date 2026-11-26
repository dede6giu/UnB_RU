# language: pt
Funcionalidade: Editar os turnos
    Como administrador
    Eu quero definir o horário de início e de fim do turno de cada refeição
    Para que as catracas e o FastPass sigam o horário do restaurante

    Contexto:
        Dado que estou logado como admin
        E que estou na página "Turnos e Time-frames"
        E que o turno do café da manhã vai de "07:00" até "09:00"
        E que o turno do almoço vai de "11:15" até "14:15"

    # Cenários positivos
    Cenário: Mudar o turno do almoço
        Quando defino o turno do almoço de "11:00" até "14:30"
        E clico no botão de salvar configuração
        Então devo ver o turno do almoço indo de "11:00" até "14:30"

    # Cenários negativos
    Esquema do Cenário: Turno do almoço inválido
        Quando defino o turno do almoço de "<início>" até "<fim>"
        E clico no botão de salvar configuração
        Então devo ver uma mensagem de turno inválido

        Exemplos:
            | início | fim   | motivo                    |
            | 14:15  | 11:15 | termina antes de começar  |
            | 08:30  | 14:15 | sobrepõe o café da manhã  |
            | 25:00  | 14:15 | horário que não existe    |
