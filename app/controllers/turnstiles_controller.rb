class TurnstilesController < ApplicationController
  layout "admin"
  before_action :set_turnstile, only: %i[ show edit update destroy ]

  # GET /turnstiles or /turnstiles.json
  def index
    @turnstiles = Turnstile.all
  end

  # GET /turnstiles/1 or /turnstiles/1.json
  def show
  end

  # GET /turnstiles/new
  def new
    @turnstile = Turnstile.new
  end

  # GET /turnstiles/1/edit
  def edit
  end

  # POST /turnstiles or /turnstiles.json
  def create
    @turnstile = Turnstile.new(turnstile_params)

    respond_to do |format|
      if @turnstile.save
        format.html { redirect_to @turnstile, notice: "Turnstile was successfully created." }
        format.json { render :show, status: :created, location: @turnstile }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @turnstile.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /turnstiles/1 or /turnstiles/1.json
  def update
    respond_to do |format|
      if @turnstile.update(turnstile_params)
        format.html { redirect_to @turnstile, notice: "Turnstile was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @turnstile }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @turnstile.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /turnstiles/1 or /turnstiles/1.json
  def destroy
    @turnstile.destroy!

    respond_to do |format|
      format.html { redirect_to turnstiles_path, notice: "Turnstile was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_turnstile
      @turnstile = Turnstile.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def turnstile_params
      params.expect(turnstile: [ :name, :operation, :restaurant_id ])
    end
end
