# Cenários @javascript rodam no Chrome headless: funciona localmente e no CI,
# onde não há display para abrir um navegador com janela.
Capybara.javascript_driver = :selenium_chrome_headless

# O Chrome 158 recusa a origem "*" que o Capybara 3.40 usa para apagar os cookies entre os cenários,
# e todo cenário depois de um @javascript falhava na limpeza.
module ApagarCookiesNoChromeNovo
  def reset!
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError
    @browser.manage.delete_all_cookies
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ApagarCookiesNoChromeNovo)
