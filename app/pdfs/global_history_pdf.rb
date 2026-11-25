class GlobalHistoryPdf
  FONTS = Rails.root.join("vendor/fonts")

  ##
  # Guarda os acessos já filtrados e os rótulos dos filtros para a geração do PDF.
  #
  # Recebe a coleção de `Access` e as strings `restaurant:`, `turnstile:` e `date:` já formatadas.
  # Não retorna valor útil; inicializa as variáveis de instância. Não altera o banco.
  def initialize(accesses, restaurant:, turnstile:, date:)
    @accesses = accesses
    @restaurant = restaurant
    @turnstile = turnstile
    @date = date
  end

  ##
  # Gera o documento com cabeçalho e tabela dos acessos.
  #
  # Não recebe argumentos. Retorna uma String com os bytes do PDF.
  # Não altera o banco de dados.
  def render
    pdf = new_document
    write_header(pdf)
    write_table(pdf)
    pdf.render
  end

  private

  ##
  # Cria o documento A4 com a fonte DejaVu (para nomes com acento).
  #
  # Não recebe argumentos. Retorna o Prawn::Document vazio; não altera o banco.
  def new_document
    pdf = Prawn::Document.new(page_size: "A4")
    pdf.font_families.update("DejaVuSans" => {
      normal: FONTS.join("DejaVuSans.ttf").to_s,
      bold: FONTS.join("DejaVuSans-Bold.ttf").to_s
    })
    pdf.font "DejaVuSans"
    pdf
  end

  ##
  # Escreve no `pdf` o título, os filtros aplicados e a hora da exportação.
  #
  # Recebe o Prawn::Document. Não retorna valor útil; o efeito é o texto adicionado ao `pdf`.
  def write_header(pdf)
    pdf.text "Histórico Global de Acessos", size: 18, style: :bold
    pdf.text "Restaurante: #{@restaurant} · Catraca: #{@turnstile} · Data: #{@date}"
    pdf.text "Exportado em #{Time.current.strftime('%d/%m/%Y %H:%M')}", size: 9
    pdf.move_down 12
  end

  ##
  # Escreve no `pdf` a tabela dos acessos, com cabeçalho em negrito.
  #
  # Recebe o Prawn::Document. Não retorna valor útil; o efeito é a tabela adicionada ao `pdf`.
  def write_table(pdf)
    pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 8 }) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
    end
  end

  ##
  # Monta as linhas da tabela: cabeçalho + uma linha por acesso.
  #
  # Não recebe argumentos (usa `@accesses`). Retorna um array de arrays de strings.
  # Não altera o banco de dados.
  def rows
    linhas = [ [ "Data e hora", "Matrícula", "Estudante", "Restaurante",
                 "Catraca", "Status", "Motivo" ] ]

    @accesses.each do |access|
      linhas << [
        access.created_at.strftime("%d/%m/%Y %H:%M:%S"),
        access.registration,
        access.student&.account&.name || "Não cadastrado",
        access.restaurant.name,
        access.turnstile.name,
        access.status == "allowed" ? "Liberado" : "Bloqueado",
        access.reason.presence || "—"
      ]
    end

    linhas
  end
end
