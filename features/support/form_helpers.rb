module FormHelpers
  def preencher(campo, valor)
    if campo == 'card-expire'
      mes, ano = valor.split('/')
      fill_in 'card-expire', with: mes
      fill_in 'card-expire-year', with: ano
    else
      fill_in campo, with: valor
    end
  end
end

World(FormHelpers)
