# PDF do Extrato e Histórico de Refeições, feito com a gem Prawn. Usa os mesmos helpers da página, então
# os valores saem escritos igual à tela.
class StatementPdf
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include StatementsHelper

  # Pasta da fonte DejaVu, que tem as letras de qualquer nome (as fontes padrão do PDF não têm "Ł").
  FONTS = Rails.root.join("vendor/fonts")

  ##
  # Guarda o estudante, os lançamentos já filtrados e os filtros escolhidos, para o cabeçalho.
  #
  # Recebe o Student, a consulta de Transaction e os valores de `period:`, `type:` e `restaurant:`
  # (este é opcional). Não altera o banco.
  def initialize(student, transactions, period:, type:, restaurant: nil)
    @student = student
    @transactions = transactions
    @period = period
    @type = type
    @restaurant = restaurant
  end

  ##
  # Monta o PDF: cabeçalho, totais e a tabela com todos os lançamentos.
  #
  # Não recebe argumentos. Retorna o conteúdo do PDF (texto binário que começa com "%PDF"); não altera o
  # banco.
  def render
    pdf = new_document
    write_header(pdf)
    write_totals(pdf)
    write_table(pdf)
    pdf.render
  end

  private

  ##
  # Cria o documento A4 com a fonte DejaVu (para nomes com acento e letras como "Ł").
  #
  # Não recebe argumentos. Retorna o Prawn::Document vazio; não altera o banco.
  def new_document
    pdf = Prawn::Document.new(page_size: "A4")
    pdf.font_families.update("DejaVuSans" => { normal: FONTS.join("DejaVuSans.ttf").to_s,
                                               bold: FONTS.join("DejaVuSans-Bold.ttf").to_s })
    pdf.font "DejaVuSans"
    pdf
  end

  ##
  # Escreve no `pdf` o título, o nome e a matrícula do estudante, os filtros e a hora da exportação.
  #
  # Recebe o Prawn::Document. Não retorna valor útil; o efeito é o texto adicionado ao `pdf`.
  def write_header(pdf)
    pdf.text "Extrato e Histórico de Refeições", size: 18, style: :bold
    pdf.text "#{@student.account.name} · matrícula #{@student.user}"
    pdf.text "Período: #{period_label(@period)} · Tipo: #{type_label(@type)} · Restaurante: #{restaurant_label(@restaurant)}"
    pdf.text "Exportado em #{Time.current.strftime('%d/%m/%Y %H:%M')}", size: 9
    pdf.move_down 12
  end

  ##
  # Escreve no `pdf` os totais do filtro (gasto, refeições, recarregado) e o saldo atual.
  #
  # Recebe o Prawn::Document. Não retorna valor útil; o efeito é o texto adicionado ao `pdf`.
  def write_totals(pdf)
    pdf.text "Total gasto: #{reais(@transactions.spent_cents)}"
    pdf.text "Refeições: #{@transactions.meals_count}"
    pdf.text "Total recarregado: #{reais(@transactions.recharged_cents)}"
    pdf.text "Saldo atual: #{reais(@student.balance_cents)}"
    pdf.move_down 12
  end

  ##
  # Escreve no `pdf` a tabela dos lançamentos, com cabeçalho em negrito e valores alinhados à direita.
  #
  # Recebe o Prawn::Document. Não retorna valor útil; o efeito é a tabela adicionada ao `pdf`.
  def write_table(pdf)
    pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 9 }) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
      column(3).align = :right
    end
  end

  ##
  # Linhas da tabela do PDF: o cabeçalho e uma linha por lançamento (data, lançamento, meio e valor).
  #
  # Não recebe argumentos. Retorna uma lista de listas de textos; não altera o banco.
  def rows
    linhas = [ [ "Data e hora", "Lançamento", "Meio", "Valor" ] ]
    @transactions.each do |transaction|
      linhas << [ entry_time(transaction), entry_label(transaction), payment_label(transaction), signed_amount(transaction) ]
    end
    linhas
  end
end
