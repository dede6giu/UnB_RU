# Cenários @javascript rodam no Chrome headless: funciona localmente e no CI,
# onde não há display para abrir um navegador com janela.
Capybara.javascript_driver = :selenium_chrome_headless

# O Chrome 158 recusa a origem "*" que o Capybara 3.40 usa para apagar os dados entre os cenários,
# e o reset! levanta InvalidArgumentError. Nesse ponto o navegador já foi para about:blank, e o
# delete_all_cookies do WebDriver (@browser.manage) só apaga os cookies da página atual, ou seja,
# nenhum. Por isso usamos o delete_all_cookies do próprio Capybara, que apaga os cookies do
# navegador inteiro via CDP (Network.clearBrowserCookies). Sem isso, a sessão de um cenário
# @javascript vazava para o próximo, e quem já estava logado era redirecionado para fora da página de login (issue #85).
module ApagarCookiesNoChromeNovo
  def reset!
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError
    delete_all_cookies
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ApagarCookiesNoChromeNovo)
