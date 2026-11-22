class AdminShiftsController < ApplicationController
  layout "admin"
  before_action :exigir_admin

  def show
    load_shifts
  end

  def update
    load_shifts
    shifts_to_save = configured_shifts

    if shifts_to_save.all?(&:valid?)
      Shift.transaction { shifts_to_save.each(&:save!) }
      redirect_to admin_shifts_path, notice: "Configuração salva com sucesso."
    else
      flash.now[:alert] = "Horário inválido. Verifique os horários e evite sobreposição entre turnos."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def exigir_admin
    return if current_admin

    redirect_to new_admin_session_path, alert: "Faça login para continuar."
  end

  def load_shifts
    @shifts = Shift::MEAL_TYPES.map do |meal_type|
      Shift.find_or_initialize_by(meal_type: meal_type)
    end
  end

  def configured_shifts
    submitted_shifts = shifts_params
    @shifts.each do |shift|
      attributes = submitted_shifts[shift.meal_type]
      shift.assign_attributes(attributes) if attributes
    end

    @shifts.select do |shift|
      shift.persisted? || [ shift.starts_at, shift.ends_at ].any?(&:present?)
    end
  end

  def shifts_params
    params.fetch(:shifts, ActionController::Parameters.new).permit(
      breakfast: [ :starts_at, :ends_at ],
      lunch: [ :starts_at, :ends_at ],
      dinner: [ :starts_at, :ends_at ]
    )
  end
end
