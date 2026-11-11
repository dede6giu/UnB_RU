class StatementPdf
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include StatementsHelper

  # as fontes que já vêm no PDF não têm letras como o "Ł" de "Łukasz", e o nome é digitado no cadastro
  FONTS = Rails.root.join("vendor/fonts")

  def initialize(student, transactions, period:, type:)
    @student = student
    @transactions = transactions
    @period = period
    @type = type
  end

  def render
    pdf = Prawn::Document.new(page_size: "A4")
    pdf.font_families.update("DejaVuSans" => { normal: FONTS.join("DejaVuSans.ttf").to_s,
                                               bold: FONTS.join("DejaVuSans-Bold.ttf").to_s })
    pdf.font "DejaVuSans"

    pdf.text "Extrato e Histórico de Refeições", size: 18, style: :bold
    pdf.text "#{@student.account.name} · matrícula #{@student.user}"
    pdf.text "Período: #{period_label(@period)} · Tipo: #{type_label(@type)}"
    pdf.text "Exportado em #{Time.current.strftime('%d/%m/%Y %H:%M')}", size: 9
    pdf.move_down 12
    pdf.text "Total gasto: #{reais(@transactions.spent_cents)}"
    pdf.text "Refeições: #{@transactions.meals_count}"
    pdf.text "Total recarregado: #{reais(@transactions.recharged_cents)}"
    pdf.text "Saldo atual: #{reais(@student.balance_cents)}"
    pdf.move_down 12
    pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 9 }) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
      column(3).align = :right
    end
    pdf.render
  end

  private

  def rows
    linhas = [ [ "Data e hora", "Lançamento", "Meio", "Valor" ] ]
    @transactions.each do |transaction|
      linhas << [ entry_time(transaction), entry_label(transaction), payment_label(transaction), signed_amount(transaction) ]
    end
    linhas
  end
end
