import { Controller } from "@hotwired/stimulus"

const SELECTED_CLASSES = ["border-primary", "bg-primary-subtle"]

// Tela de Configuração de Ponto: filtra as catracas pela unidade escolhida,
// mantém o resumo da vinculação atualizado e faz o relógio do servidor andar.
export default class extends Controller {
  static targets = ["restaurantInput", "turnstileInput", "group", "summaryRestaurant", "summaryTurnstile", "clock"]
  static values = { serverTime: Number }

  connect() {
    this.clockOffset = this.serverTimeValue - Date.now()
    this.clockTimer = setInterval(() => this.tick(), 1000)
    this.tick()
    this.sync()
  }

  disconnect() {
    clearInterval(this.clockTimer)
  }

  sync() {
    const restaurant = this.restaurantInputTargets.find((input) => input.checked)

    this.groupTargets.forEach((group) => {
      group.hidden = group.dataset.restaurantId !== restaurant?.value
    })
    this.turnstileInputTargets.forEach((input) => {
      if (input.closest("[hidden]")) input.checked = false
    })

    const turnstile = this.turnstileInputTargets.find((input) => input.checked)
    this.summaryRestaurantTarget.textContent = restaurant?.dataset.label ?? "Nenhuma selecionada"
    this.summaryTurnstileTarget.textContent = turnstile?.dataset.label ?? "Nenhuma selecionada"

    const inputs = [...this.restaurantInputTargets, ...this.turnstileInputTargets]
    inputs.forEach((input) => {
      input.closest("label").classList.toggle(SELECTED_CLASSES[0], input.checked)
      input.closest("label").classList.toggle(SELECTED_CLASSES[1], input.checked)
    })
  }

  tick() {
    this.clockTarget.textContent = new Date(Date.now() + this.clockOffset)
      .toLocaleTimeString("pt-BR", { timeZone: "America/Sao_Paulo" })
  }
}
