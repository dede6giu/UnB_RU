Feature: Page scopes
    As the owner
    I want to allow only correctly authenticated people to access certain pages

    # Positive Scenarios
    Scenario Outline: Correct access
        Given I am an <scope>
        When I go to the "<page_name>" page
        Then I should be on the "<page_name>" page

        Examples:
            | scope        | page_name                         |
            | Unregistered | Index                             |
            | Unregistered | Autenticação de Estudante         |
            | Unregistered | Autenticação de Operador          |
            | Unregistered | Autenticação de Admin             |
            | Student      | Portal do Estudante               |
            | Student      | Extrato de Refeições              |
            | Student      | Recarga de Saldos                 |
            | Student      | Sorteio FastPass                  |
            | Operator     | Configuração de Ponto             |
            | Operator     | Terminal de Validação             |
            | Operator     | Histórico Local de Acessos        |
            | Admin        | Relatório Global de Operação      |
            | Admin        | Gestão de Restaurantes e Catracas |
            | Admin        | Cadastrar Restaurante             |
            | Admin        | Manejar Restaurante               |
            | Admin        | Cadastrar Catraca                 |
            | Admin        | Manejar Catraca                   |
            | Admin        | Turnos e Time-frames              |
            | Admin        | Vagas e Cotas FastPass            |

    # Negative Scenarios
    Scenario Outline: Incorrect access redirect
        Given I am an <scope>
        When I go to the "<page_name>" page
        Then I should be on the "<page_fallback>" page

        Examples:
            | scope        | page_name                         | page_fallback                |
            | Unregistered | Portal do Estudante               | Autenticação de Estudante    |
            | Unregistered | Extrato de Refeições              | Autenticação de Estudante    |
            | Unregistered | Recarga de Saldos                 | Autenticação de Estudante    |
            | Unregistered | Sorteio FastPass                  | Autenticação de Estudante    |
            | Unregistered | Configuração de Ponto             | Autenticação de Operador     |
            | Unregistered | Terminal de Validação             | Autenticação de Operador     |
            | Unregistered | Histórico Local de Acessos        | Autenticação de Operador     |
            | Unregistered | Relatório Global de Operação      | Autenticação de Admin        |
            | Unregistered | Gestão de Restaurantes e Catracas | Autenticação de Admin        |
            | Unregistered | Cadastrar Restaurante             | Autenticação de Admin        |
            | Unregistered | Manejar Restaurante               | Autenticação de Admin        |
            | Unregistered | Cadastrar Catraca                 | Autenticação de Admin        |
            | Unregistered | Manejar Catraca                   | Autenticação de Admin        |
            | Unregistered | Turnos e Time-frames              | Autenticação de Admin        |
            | Unregistered | Vagas e Cotas FastPass            | Autenticação de Admin        |
            | Student      | Index                             | Portal do Estudante          |
            | Student      | Autenticação de Estudante         | Portal do Estudante          |
            | Student      | Autenticação de Operador          | Portal do Estudante          |
            | Student      | Autenticação de Admin             | Portal do Estudante          |
            | Student      | Configuração de Ponto             | Portal do Estudante          |
            | Student      | Terminal de Validação             | Portal do Estudante          |
            | Student      | Histórico Local de Acessos        | Portal do Estudante          |
            | Student      | Relatório Global de Operação      | Portal do Estudante          |
            | Student      | Gestão de Restaurantes e Catracas | Portal do Estudante          |
            | Student      | Cadastrar Restaurante             | Portal do Estudante          |
            | Student      | Manejar Restaurante               | Portal do Estudante          |
            | Student      | Cadastrar Catraca                 | Portal do Estudante          |
            | Student      | Manejar Catraca                   | Portal do Estudante          |
            | Student      | Turnos e Time-frames              | Portal do Estudante          |
            | Student      | Vagas e Cotas FastPass            | Portal do Estudante          |
            | Operator     | Index                             | Configuração de Ponto        |
            | Operator     | Autenticação de Estudante         | Configuração de Ponto        |
            | Operator     | Autenticação de Operador          | Configuração de Ponto        |
            | Operator     | Autenticação de Admin             | Configuração de Ponto        |
            | Operator     | Portal do Estudante               | Configuração de Ponto        |
            | Operator     | Extrato de Refeições              | Configuração de Ponto        |
            | Operator     | Recarga de Saldos                 | Configuração de Ponto        |
            | Operator     | Sorteio FastPass                  | Configuração de Ponto        |
            | Operator     | Relatório Global de Operação      | Configuração de Ponto        |
            | Operator     | Gestão de Restaurantes e Catracas | Configuração de Ponto        |
            | Operator     | Cadastrar Restaurante             | Configuração de Ponto        |
            | Operator     | Manejar Restaurante               | Configuração de Ponto        |
            | Operator     | Cadastrar Catraca                 | Configuração de Ponto        |
            | Operator     | Manejar Catraca                   | Configuração de Ponto        |
            | Operator     | Turnos e Time-frames              | Configuração de Ponto        |
            | Operator     | Vagas e Cotas FastPass            | Configuração de Ponto        |
            | Admin        | Index                             | Relatório Global de Operação |
            | Admin        | Autenticação de Estudante         | Relatório Global de Operação |
            | Admin        | Autenticação de Operador          | Relatório Global de Operação |
            | Admin        | Autenticação de Admin             | Relatório Global de Operação |
            | Admin        | Portal do Estudante               | Relatório Global de Operação |
            | Admin        | Extrato de Refeições              | Relatório Global de Operação |
            | Admin        | Recarga de Saldos                 | Relatório Global de Operação |
            | Admin        | Sorteio FastPass                  | Relatório Global de Operação |
            | Admin        | Configuração de Ponto             | Relatório Global de Operação |
            | Admin        | Terminal de Validação             | Relatório Global de Operação |
            | Admin        | Histórico Local de Acessos        | Relatório Global de Operação |
